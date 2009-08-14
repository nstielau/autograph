# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{autograph}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Stielau"]
  s.date = %q{2009-08-13}
  s.default_executable = %q{autograph}
  s.description = %q{FIX (describe your package)}
  s.email = ["nick.stielau@gmail.com"]
  s.executables = ["autograph"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "TODO", "bin/autograph", "lib/autograph.rb", "lib/autograph/autoperf.rb", "lib/autograph/graph_series.rb", "lib/autograph/pdf_formatters.rb", "lib/autograph/report.html.erb", "lib/autograph/graph_renderers/base_renderer.rb", "lib/autograph/graph_renderers/gchart_renderer.rb", "lib/autograph/graph_renderers/rasterized_scruffy_renderer.rb", "lib/autograph/graph_renderers/scruffy_renderer.rb", "script/console", "script/destroy", "script/generate", "test/test_autograph.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{autograph}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{FIX (describe your package)}
  s.test_files = ["test/test_autograph.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.4.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.4.1"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.4.1"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
