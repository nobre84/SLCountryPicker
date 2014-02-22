CountryPicker
=============

Country picker table view controller for iOS7+.  
It has convinient search and dynamic fonts support.

![](https://bitbucket.org/shmidt/slcountrypicker/raw/bcf4782680ae9595c952726dd086b39c02970bd3/1.jpg)![](https://bitbucket.org/shmidt/slcountrypicker/raw/7aab1cc8eca15c9e831c0bf4d998660ab5dbef07/2.jpg)


##Supported Platforms

- iOS 7+

##Installing

In order to install `CountryPicker`, you'll need to copy the `CountryPicker` folder into your Xcode project. 

###Usage

In order to use `CountryPicker`, you'll need to 
`#import "SLCountryPickerViewController.h"`
 and include the following code in your project:

    SLCountryPickerViewController *vc = [[SLCountryPickerViewController alloc]init];
    vc.completionBlock = ^(NSString *country, NSString *code){
    //Your code here
        _countryNameLabel.text = country;
        _countryImageView.image = [UIImage imageNamed:code];
        _countryCodeLabel.text = code;

    };
    //
    [self.navigationController pushViewController:vc animated:YES];
    
Where in completion block you get country and country code strings. 
 
##Credits & Contributors
Beautiful flaga images are taken from <https://github.com/koppi/iso-country-flags-svg-collection>

`CountryPicker` was written by [Dmitry Shmidt][1].
Website: [www.shmidtlab.com][2]  
Twitter: [http://twitter.com/shmidtlab][3]  
  [1]: http://www.shmidtlab.com
  [2]: www.shmidtlab.com   
  [3]: http://twitter.com/shmidtlab
  E-mail <mail@shmidtlab.com>  
##License

`CountryPicker` is licensed under the MIT license.