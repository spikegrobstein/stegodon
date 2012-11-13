configuration :default do
  host 'db001.prod'
  username 'postgres'
  password 'asdfasdf'
  port 5432
end

# each block is really a configuration.
# configurations are just ways of setting defaults for something
# on day 1, all attributes will be freeform
configuration :exchange_prod do
  configuration :default
  database 'exchange_prod'
end

# to start, we will just support warehouse, backup and restore
# each block will take all necessary configuration params
# inheritance will be a day 2 solution.
warehouse 'exchange_uploads' do
  configuration :exchange_prod

  interval :monthly
  indexes true
end

# define a backup. give it a database name and a destination
backup :exchange_prod do
  filename 'exchnage_prod_daily'
end

# define a globals backup. just give it a destination filename
backup_globals do
  configuration :default
end

backup :exchange_sandbox

restore :exchange_prod do
  filename 'exchange_prod_daily'
end

