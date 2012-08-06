actions :supervise

attribute :name, :kind_of => String, :name_attribute => true
attribute :command, :kind_of => String, :required => true
attribute :directory, :kind_of => String
attribute :autostart, :kind_of => [TrueClass,FalseClass], :default => true
attribute :autorestart, :kind_of => [String,TrueClass,FalseClass], :default => "unexpected"
attribute :user, :kind_of => String
attribute :template, :kind_of => String, :default => "supervised-program.conf.erb"
attribute :cookbook, :kind_of => String, :default => "supervisord"
attribute :stdout_logfile, :kind_of => String
attribute :stderr_logfile, :kind_of => String
attribute :startsecs, :kind_of => [Fixnum,String]
attribute :stopwaitsecs, :kind_of => [Fixnum,String]
attribute :priority, :kind_of => [Fixnum,String]
attribute :numprocs, :kind_of => [Fixnum,String]
