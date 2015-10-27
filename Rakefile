task :html => Rake::FileList["src/*.slim"].pathmap("%{^src/,compiled/}X.html")

rule ".html" => [->(file) { file.pathmap("%{^compiled/,src/}X.slim") }, "compiled"] do |t|
  sh "slimrb --pretty #{t.source} > #{t.name}"
end


task :js => Rake::FileList["src/*.coffee"].pathmap("%{^src/,compiled/}X.js")

rule ".js" => [->(file) { file.pathmap("%{^compiled/,src/}X.coffee") }, "compiled"] do |t|
  sh "coffee --compile --map --output compiled #{t.source}"
end


task :css => Rake::FileList["src/*.sass"].pathmap("%{^src/,compiled/}X.css")

rule ".css" => [->(file) { file.pathmap("%{^compiled/,src/}X.sass") }, "compiled"] do |t|
  sh "sass --unix-newlines #{t.source} #{t.name}"
end


directory "compiled"

task :build => [:html, :js, :css]
task :default => :build

task :clean do
  rm_rf "compiled"
end
