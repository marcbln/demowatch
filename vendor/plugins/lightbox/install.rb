# Install hook code here

require 'ftools'

plugins_dir = File.expand_path(".")
p plugins_dir
lightbox_dir = plugins_dir
#lightbox_dir = File.join(plugins_dir, 'lightbox')
root_dir = File.join(lightbox_dir, '..', '..', '..')

File.copy File.join(lightbox_dir, 'javascripts', 'lightbox.js'), File.join(root_dir, 'public', 'javascripts', 'lightbox.js')
File.copy File.join(lightbox_dir, 'stylesheets', 'lightbox.css'), File.join(root_dir, 'public', 'stylesheets', 'lightbox.css')
File.copy File.join(lightbox_dir, 'images', 'lightbox_blank.gif'), File.join(root_dir, 'public', 'images', 'lightbox_blank.gif')
File.copy File.join(lightbox_dir, 'images', 'lightbox_overlay.png'), File.join(root_dir, 'public', 'images', 'lightbox_overlay.png')
File.copy File.join(lightbox_dir, 'images', 'lightbox_close.gif'), File.join(root_dir, 'public', 'images', 'lightbox_close.gif')
