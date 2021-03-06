#
# Copyright 2017, Don O'Neill (sntxrr+github@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe 'git::default'

# Create a robots group
group 'robots' do
  action :create
  notifies :create, 'user[hubot]', :immediately
end

# Create a hubot user
user 'hubot' do
  action :create # default action
  non_unique false
  group 'robots'
end

# Create user sntxrr so test kitchen doesn't fail
user 'sntxrr' do
  action :create
  non_unique false
end

# Create the deployment user
user 'deploy' do
  action :create
  non_unique false
end

# make sure deployment user has sudo
group 'create deploy sudo' do
  group_name 'sudo'
  members 'deploy'
  action :modify
  append true
end

# Clone the source code from GitHub.
#
# action: defaults to sync (sync each time)
# revision: defaults to whatever is set on GitHub
git '/srv/hangops-jobbot' do
  repository 'https://github.com/rrxtns/hangops-jobbot.git'
end

# Install nodejs and hubot dependencies
include_recipe 'hangops-jobbot::nodejs'

# Install Runit
include_recipe 'runit::default'

# Install Redis
include_recipe 'redis::install_from_package'

# get databag data
varapikey = data_bag_item('slackapikey', node.chef_environment)

# set some ENV vars for RUNIT
node.override['hangops-jobbot']['config'] = {
  'HUBOT_SLACK_TOKEN' => varapikey['key'],
  'HUBOT_LOG_LEVEL' => 'info',
  'REDIS_URL' => 'redis://127.0.0.1:6379/hangops-jobbot',
  'HUBOT_SLACK_BOTNAME' => 'hangops-jobbot',
  'HUBOT_SLACK_TEAM' => 'hangops',
  'HUBOT_WHITELIST' => 'job_board,job_board_botbuild,hangops-jobbot-test',
  'HUBOT_RATE_LIMIT_SILENT' => 'false',
  'HUBOT_RATE_LIMIT_NOTIFY_PERIOD' => '30',
  'HUBOT_RATE_LIMIT_CMD_PERIOD' => '0',
  'HUBOT_RATE_LIMIT_NOTIFY_MSG' => 'rate limiting in effect!'
}

include_recipe 'runit'

include_recipe 'hangops-jobbot::_runit'
