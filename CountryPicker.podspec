Pod::Spec.new do |s|

  s.name         = "SLCountryPicker"
  s.version      = "0.0.1"
  s.summary      = "Country picker table view controller for iOS7+"

  s.description  = <<-DESC
                   Shows a searchable list of countries.

  s.homepage     = "https://bitbucket.org/shmidt/slcountrypicker/overview"
  # s.screenshots  = "https://bitbucket.org/shmidt/slcountrypicker/raw/7aab1cc8eca15c9e831c0bf4d998660ab5dbef07/1.jpg", "https://bitbucket.org/shmidt/slcountrypicker/raw/7aab1cc8eca15c9e831c0bf4d998660ab5dbef07/2.jpg"
  s.license      = 'MIT'
  s.author       = { "Dmitry Shmidt" => "mail@shmidtlab.com" }
  s.platform     = :ios, '7.0'
  s.social_media_url = 'https://twitter.com/shmidtlab'
  s.source       = { :hg => "https://shmidt@bitbucket.org/shmidt/slcountrypicker", :commit => "487d7930a000a9edfc750c6ac57e9bf0ba9d42e8" }
  s.source_files  = 'CountryPicker', 'CountryPicker/**/*.{h,m}'

  s.resource  = "CountryPicker/CountriesFlags36px.xcassets"
  s.preserve_paths = "CountryPicker/CountriesFlags36px.xcassets/*"

  s.requires_arc = true

end
