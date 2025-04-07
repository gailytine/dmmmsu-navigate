# This file is used by Flutter's iOS build system
require 'fileutils'

def install_all_flutter_pods(flutter_application_path)
  flutter_root = File.join(flutter_application_path, '..', '..')
  pod 'Flutter', :path => File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine', 'ios')
end
