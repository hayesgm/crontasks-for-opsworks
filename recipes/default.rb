
node[:crontasks].each do |application, tasks|

  app_root = "#{node[:deploy][application][:deploy_to]}/current"
  shared_root = "#{node[:deploy][application][:deploy_to]}/shared"
  rails_env = node[:deploy][application][:rails_env] # this is kind of hyper specific
  
  tasks.each do |task, props|
    if props[:layers] && ( node[:opsworks][:instance][:layers] & props[:layers] ).count == 0 # are we part of specified layers?
      Chef::Log.debug("Skipping `crontasks` for task `#{task}` as we [#{node[:opsworks][:instance][:layers]}] are not part of required layers `#{props[:layers]}`")
      next
    end

    cron task.to_s do
      minute props[:minute].to_s if props[:minute]
      hour props[:hour].to_s if props[:hour]
      weekday props[:weekday].to_s if props[:weekday]
      user props[:user] || "deploy" # default user
      home props[:home] || "/home/deploy" # default home
      shell props[:shell] if props[:shell]
      path props[:path] if props[:path]
      
      command %Q{
        cd #{props[:wd]||app_root} &&
        #{props[:cmd]}
        >> #{shared_root}/log/cron.#{task.to_s}.log 2>&1
      }.gsub("{app_root}",app_root).gsub("{shared_root}",shared_root).gsub('{rails_env}',rails_env).gsub(/\s+/," ")

      only_if do File.exists?(app_root) && File.exists?(shared_root) end
      action props[:action] || :create # to remove old cron tasks
    end
  end
end