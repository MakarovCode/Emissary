
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "emissary-ruby"
  spec.version       = "0.0.6"
  spec.authors       = ["MakarovCode"]
  spec.email         = ["simoncorreaocampo@gmail.com"]

  spec.summary       = "Simple error catcher integrated with services like Discord and Trello, use chatbots to monitor your application and server. Receive error catching reports to a Discord Server Channel, and use chatbots to send commands and fetch reports."
  spec.homepage      = "https://github.com/MakarovCode/Emissary"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = ["emissary.gemspec", "README.md", "CODE_OF_CONDUCT.md"] + `git ls-files | grep -E '^(bin|lib|web)'`.split("\n")
  # spec.bindir        = "exe"
  spec.executables   = ["emissary"]
  spec.require_paths = ["lib"]

  # spec.add_development_dependency "bundler", "~> 2.0"
  # spec.add_development_dependency "rake", "~> 13.0"
  # spec.add_development_dependency "discordrb", "~> 3.4.2"
  # spec.add_development_dependency "ruby-trello", "~> 3.0.0"
  #
  # spec.add_runtime_dependency "bundler", "~> 2.0"
  # spec.add_runtime_dependency "rake", "~> 13.0"
  # spec.add_runtime_dependency "discordrb", "~> 3.4.2"
  # spec.add_runtime_dependency "ruby-trello", "~> 3.0.0"
end
