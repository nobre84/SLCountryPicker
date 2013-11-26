Pod::Spec.new do |s|

  s.name         = "SLCountryPicker"
  s.version      = "0.0.1"
  s.summary      = "Country picker table view controller for iOS7+"

  s.description  = <<-DESC
                   Shows a searchable list of countries.

  s.homepage     = "https://bitbucket.org/shmidt/slcountrypicker/overview"
  # s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license      = 'MIT'
  s.author       = { "Dmitry Shmidt" => "mail@shmidtlab.com" }
  s.platform     = :ios, '7.0'

  s.source       = { :git => "https://shmidt@bitbucket.org/shmidt/slcountrypicker", :commit => "487d7930a000a9edfc750c6ac57e9bf0ba9d42e8" }
  s.source_files  = 'CountryPicker', 'CountryPicker/**/*.{h,m}'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.requires_arc = true

end
