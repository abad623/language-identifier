require 'bundler/gem_tasks'
require_relative 'ext/hack/support'

desc 'Compiles all required Perl modules'
task :compile do
  perl_extensions.each do |directory|
    compile_perl_extension(directory)
  end
end
