# encoding; utf-8
class CalendarController < ApplicationController

  require 'google/api_client'
  require 'date'

  def index

    result = @client.execute(:api_method => @service.calendar_list.list)
    while true
      @entries = result.data.items
      @entries.each do |e|
        puts e.summary
      end
      if !(page_token = result.data.next_page_token)
        break
      end
      result = @client.execute(:api_method => @service.calendar_list.list,
                               :parameters => {'pageToken' => page_token})
    end

    # 前月の一日から末日までを計算
    day = Date.today
    @start_date = Date.new(day.year,day.month, 1)
    @end_date = @start_date - 1
    @start_date = @start_date << 1


    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @entries }
    end

  end

  def getDetail

    puts params
    @params = params


    if params[:callist].nil?
      redirect_to("calender/index")
    end

    start_date = DateTime.new(params[:start][:year].to_i, params[:start][:month].to_i, params[:start][:day].to_i, 0, 0, 0, 0.375)
    end_date = DateTime.new(params[:end][:year].to_i, params[:end][:month].to_i,  params[:end][:day].to_i, 23, 59, 59, 0.375)
    puts start_date
    puts end_date

    page_token = nil
    result = @client.execute(:api_method => @service.events.list,
                             :parameters => {'calendarId' => params[:callist],
                                             'orderBy' => 'startTime',
                                             'singleEvents' => true,
                                             'timeMax' => end_date,
                                             'timeMin' => start_date
                             })

    @events = []
    @summary = Hash.new()
    while true
      if result.data.items.nil?
        break
      end
      events_e = result.data.items
      @events.concat(events_e)

      if ('1' == params[:summary])
        events_e.each do |e|
          puts 'sum:' + e.summary
          # 経過時間を計算
          puts 'e-time:' + e.end.dateTime.strftime('%H:%M')
          puts 's-time:' + e.start.dateTime.strftime('%H:%M')
          elapsedtime = e.end.dateTime.to_time.to_i - e.start.dateTime.to_time.to_i
          puts 'time:' + elapsedtime.to_s
          if (nil == @summary[e.summary])
            @summary[e.summary] = {:p1 => elapsedtime}
          else
            @summary[e.summary] = {:p1 => @summary[e.summary][:p1] + elapsedtime}
          end
        end
      end

      if !(page_token = result.data.next_page_token)
        break
      end
      result = @client.execute(:api_method => @service.events.list,
                               :parameters => {'calendarId' => params[:callist],
                                               'pageToken' => page_token,
                                               'orderBy' => 'startTime',
                                               'singleEvents' => true,
                                               'timeMax' => end_date,
                                               'timeMin' => start_date
                               })
    end

    # summryの書式変更
    @allSum = 0
    allSum_tmp = 0
    @summary.each do |k,v|
      # 秒数切り捨て
      v[:p1] = v[:p1] /60
      @allSum = @allSum + v[:p1]
      hour = v[:p1] / 60
      minutes = v[:p1] % 60
      if (30 > minutes)
        hour2 = hour
        minutes2  = 0
      else
        hour2 = hour
        minutes2 = 5
      end
      allSum_tmp = allSum_tmp + (hour2 + (minutes2 * 0.1))
      @summary[k] = {:p1 =>  hour.to_s + ':' +  '%02d'%minutes, :p2 => hour2.to_s + '.' + minutes2.to_s}
      puts @summary[k]
    end

    hour = @allSum / 60
    minutes = @allSum % 60
    # @allSum2 = {:p1 =>  hour.to_s + ':' +  '%02d'%minutes, :p2 => allSum_tmp.to_s}

    @summary[t('view.summry.sum')] = {:p1 =>  hour.to_s + ':' +  '%02d'%minutes, :p2 => allSum_tmp.to_s}

    if params[:newtab] == 'newtab'
      puts 'newtab'
      respond_to do |format|
        format.html # show.html.erb
        format.json { renderå :json => @events }
      end
    elsif params[:gdrive] = 'gdrive'
      puts 'googleDrive'
      google_data = google_puts(start_date.strftime('%Y-%m-%d') + ' - ' + end_date.strftime('%Y-%m-%d'))

      if !google_data.nil?
        puts google_data.alternateLink;
        puts google_data.title;
        puts google_data.mimeType;
        redirect_to(google_data.alternateLink)
      end
    end

  end

  MIME_TYPE = 'application/vnd.google-apps.spreadsheet'

  def google_puts(title)
    file_name = 'Time Report ' + title
    drive = @client.discovered_api('drive', 'v2')
    file = drive.files.insert.request_schema.new({
                                                     'title' => file_name,
                                                     'description' => title + 'working time Report',
                                                     'mimeType' => MIME_TYPE
                                                 })
    # Set the parent folder.
    #  media = Google::APIClient::UploadIO.new(file_name, MIME_TYPE)
    result = @client.execute(
        :tilte => file_name,
        :api_method => drive.files.insert,
        :body_object => file,
        # :media => @summary,
        :parameters => {
            # 'uploadType' => 'resumable',
            # 'alt' => 'json'
        }
    )
    if result.status == 200
      return result.data
    else
      puts "An error occurred: #{result.data['error']['message']}"
      return nil
    end
  end

  def prepare_data(body)

    @summary.each do |k, v|

    end
  end

end
