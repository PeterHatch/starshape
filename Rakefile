task :html => Rake::FileList["src/*.slim"].pathmap("%{^src/,compiled/}X.html")

rule ".html" => [->(file) { file.pathmap("%{^compiled/,src/}X.slim") }, "compiled"] do |t|
  sh "slimrb --pretty #{t.source} > #{t.name}"
end


task :js => "compiled/starshape.js"

source_files = Rake::FileList["src/*.coffee"]
file "compiled/starshape.js" => source_files + ["compiled"] do |t|
	sh "coffee --compile --map --join compiled/starshape.js #{source_files}"
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
