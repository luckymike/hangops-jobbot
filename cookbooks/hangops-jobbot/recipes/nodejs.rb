
# apt update
include_recipe 'apt::default'

# Install the latest Node.js. default action install included for clarity
package 'nodejs' do
  action :install
  retries 3
end

package 'npm' do
  action :install
  retries 3
end
# include_recipe 'nodejs::nodejs_from_package'
# include_recipe 'nodejs::npm'

# Install coffeescript globally. default action install included for clarity
nodejs_npm 'coffeescript' do
  action :install
end

# Run `npm install` to install dependencies
execute 'install-dependencies' do
  command 'cd /srv/hubot;sudo npm install'
end
