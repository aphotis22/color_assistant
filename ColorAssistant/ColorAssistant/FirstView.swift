//
//  FirstView.swift
//  ColorAssistant
//
//  Created by Likhon Gomes on 11/11/19.
//  Copyright © 2019 Likhon Gomes. All rights reserved.
//

import UIKit
import Files
import GRDB
import AVFoundation
import WebKit
class FirstView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let captureImageView = UIImageView()
    var outputImage = UIImage()
    let cardView = UIView()
    let dismissButton = UIButton()
    
    
    
    




	  let wheel = WKWebView()

	func setupColorWheel(HTML:String) {
			cardView.addSubview(wheel)
			wheel.translatesAutoresizingMaskIntoConstraints = false
        wheel.bottomAnchor.constraint(equalTo: cardView.topAnchor, constant: -20).isActive = true
        wheel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
			//wheel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
			//wheel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
			wheel.heightAnchor.constraint(equalToConstant: 200).isActive = true
			wheel.widthAnchor.constraint(equalToConstant: 200).isActive = true


			wheel.loadHTMLString(HTML, baseURL: nil)
			//wheel.frame = wheelsize
			wheel.center = cardView.center
            wheel.backgroundColor = .clear
            wheel.isOpaque = true
		}



	func wheelSetValue(r:CGFloat,g:CGFloat,b:CGFloat) -> String {
		let HTML = """
		<div class="color-space"></div>
		<script>function ColorPicker(element) {
			this.element = element;

			this.init = function() {
				var diameter = this.element.offsetWidth;

				var canvas = document.createElement('canvas');
				canvas.height = diameter;
				canvas.width = diameter,
				this.canvas = canvas;

				this.renderColorMap();

				element.appendChild(canvas);

				this.setupBindings();
			};

			this.renderColorMap = function() {
				var canvas = this.canvas;
				var ctx = canvas.getContext('2d');

				var radius = canvas.width / 2;
				var toRad = (2 * Math.PI) / 360;
				var step = 1 / radius;

				ctx.clearRect(0, 0, canvas.width, canvas.height);

				var cx = cy = radius;
				for(var i = 0; i < 360; i += step) {
					var rad = i * toRad;
					var x = radius * Math.cos(rad),
						y = radius * Math.sin(rad);

					ctx.strokeStyle = 'hsl(' + i + ', 100%, 50%)';

					ctx.beginPath();
					ctx.moveTo(radius, radius);
					ctx.lineTo(cx + x, cy + y);
					ctx.stroke();
				}

						// draw saturation gradient
				var grd = ctx.createRadialGradient(cx,cy,0,cx,cx,radius);
				grd.addColorStop(0,"white");
					  grd.addColorStop(1,'rgba(255, 255, 255, 0)');
				ctx.fillStyle = grd;
				//ctx.fillStyle = 'rgb(255, 255, 255)';
				ctx.beginPath();
				ctx.arc(cx, cy, radius, 0, Math.PI * 2, true);
				ctx.closePath();
				ctx.fill();

				// render the rainbow box here ----------
			};

			this.renderMouseCircle = function(x, y) {
				var canvas = this.canvas;
				var ctx = canvas.getContext('2d');

				ctx.strokeStyle = 'rgb(255, 255, 255)';
				ctx.fillStyle = 'rgba(0, 0, 0, 0.5)'
				ctx.lineWidth = '3';
				ctx.beginPath();
				ctx.arc(x, y, 10, 0, Math.PI * 2, true);
				ctx.closePath();
				ctx.fill();
				ctx.stroke();
			};

			this.setupBindings = function() {
				var canvas = this.canvas;
				var ctx = canvas.getContext('2d');
				var self = this;

				canvas.addEventListener('click', function(e) {
					var x = e.offsetX || e.clientX - this.offsetLeft;
					var y = e.offsetY || e.clientY - this.offsetTop;

					var imgData = ctx.getImageData(x, y, 1, 1).data;
					//var selectedColor = new Color(imgData[0], imgData[1], imgData[2]);
					// do something with this

					self.renderMouseCircle(x, y);
				}, false);
			};

			function rgbToHsv(r, g, b){
				r = r/255, g = g/255, b = b/255;
				var max = Math.max(r, g, b), min = Math.min(r, g, b);
				var h, s, v = max;

				var d = max - min;
				s = max == 0 ? 0 : d / max;

				if(max == min){
					h = 0; // achromatic
				}else{
					switch(max){
						case r: h = (g - b) / d + (g < b ? 6 : 0); break;
						case g: h = (b - r) / d + 2; break;
						case b: h = (r - g) / d + 4; break;
					}
					h /= 6;
				}

				return [h, s, v];
			}

			this.plotRgb = function(r, g, b) {
					var canvas = this.canvas;
				var ctx = canvas.getContext('2d');

				var [h, s, v] = rgbToHsv(r, g, b);
				var theta = h * 2 * Math.PI;
				var maxRadius = canvas.width / 2;
				var r = s * maxRadius;
				var x = r * Math.cos(theta) + maxRadius,
					y = r * Math.sin(theta) + maxRadius;
				this.renderMouseCircle(x, y);
			}

			this.init();
		}

		var pick = new ColorPicker(document.querySelector('.color-space'));

		var RGBList = [
			{'r':\(r*255),'g':\(g*255),'b':\(b*255)}
		];

		RGBList.forEach(function (color) {
			pick.plotRgb(color.r, color.g, color.b);
		})
		</script>
		"""
		return HTML
	}
	let label = UILabel()
    let openCamera = UIButton()
	var img = #imageLiteral(resourceName: "stacked")
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
	fileprivate func colorWheel(_ image: UIImage) {
		let centX = image.size.width/2
		let centY = image.size.height/2
		let centerColor = image.averageColor(xCoord: Int(centX), yCoord: Int(centY))
		let breakColorComp = centerColor!.cgColor.components //need to break into array
		let r = breakColorComp![0]//red
		let g = breakColorComp![1]//green
		let b = breakColorComp![2]//blue
		DispatchQueue.main.async {
			//self.view.backgroundColor = centerColor
			self.setupColorWheel(HTML: self.wheelSetValue(r: r, g: g, b: b))//color wheel added to screen
			self.label.text = centerColor?.description
			
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		//camera()
		var image = img

        
        
        cardViewSetup()
		colorWheel(image)
		if #available(iOS 13, *) {
			
		} else {
			let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
			
			downSwipe.direction = .down
			cardView.addGestureRecognizer(downSwipe)
			
			
		}

    }
    
    
	@objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
			
		if (sender.direction == .down) {
				print("Swipe down")
			dismissButtonClicked()
			
		}
			
	}
    
    
    
    
    func captureImageViewSetup() {
        view.addSubview(captureImageView)
        captureImageView.translatesAutoresizingMaskIntoConstraints = false
        captureImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        captureImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        captureImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        captureImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        captureImageView.image = outputImage
    }
    
    func cardViewSetup() {
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10
    }
    
    func dismissButtonSetup() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dismissButton.bottomAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
        dismissButton.addTarget(self, action: #selector(dismissButtonClicked), for: .touchUpInside)
    }
    
    @objc func dismissButtonClicked() {
        dismiss(animated: true, completion: nil)
    }

    
    
	func camera()  {
		let vc = UIImagePickerController()
		vc.sourceType = .camera
		vc.allowsEditing = true
		vc.delegate = self
		present(vc, animated: true)
	}
    
    func setuplabel() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 100).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        
        //label.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.text = "Color Assistant"
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.backgroundColor = .clear
        label.textAlignment = .center
        
        //label.textColor = .red

    }
	
	let bundle = try! Folder(path: Bundle.main.bundlePath)
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true)

		guard let image = info[.editedImage] as? UIImage else {
			print("No image found")
			return
		}
		
		
		let imageName = UUID().uuidString
		let pathToImage = image.save(imageName)
//		bundle.createFile(named: "image_\(image.description)")
        let centX = Int(image.size.width / 2) - 15
        let centY = Int(img.size.height / 2) - 15

        let centerColor = image.averageColor(xCoord: centX, yCoord: centY)
		let breakColorComponents = centerColor?.cgColor.components
		let date = Date()
//		var war = Wardrobe(id: nil, name: imageName, path: pathToImage, red: breakColorComponents![0], green: breakColorComponents![1], blue: breakColorComponents![2], alpha: 1.0, dateAdded: date)
//		try! dbQueue.write { db in
//			try war.insert(db)
//		}
		
		DispatchQueue.main.async {
				self.view.backgroundColor = centerColor
					self.setupColorWheel(HTML: self.wheelSetValue(r: breakColorComponents![0], g: breakColorComponents![1], b: breakColorComponents![2]))
                self.label.text = centerColor?.description

			}
		// print out the image size as a test
		print(image.size)
	}
	func openCameraSetup() {
		view.addSubview(openCamera)
		openCamera.translatesAutoresizingMaskIntoConstraints = false
		openCamera.heightAnchor.constraint(equalToConstant: 50).isActive = true
		openCamera.widthAnchor.constraint(equalToConstant: 200).isActive = true
		//openCamera.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
		//openCamera.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        openCamera.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        openCamera.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		openCamera.backgroundColor = .blue
		openCamera.addTarget(self, action: #selector(openCameraClicked), for: .touchUpInside)
        openCamera.setTitle("Camera", for: .normal)
        openCamera.setTitleColor(.white, for: .normal)
		//openCamera.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		//openCamera.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
	}

	@objc func openCameraClicked() {
		print("Button Clicked")
		camera()
	}


}
extension UIImage {
    func averageColor(xCoord: Int, yCoord : Int) -> UIColor?{//returns average color within 30X30 square
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: CGFloat(xCoord), y: CGFloat(yCoord), z: 30, w: 30)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
	func getPixelColor(pos: CGPoint) -> UIColor {//Returns pixel color at position
		let pixelData = self.cgImage!.dataProvider!.data
		let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
		let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
		let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
		let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
		let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
		let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

		return UIColor(red: r, green: g, blue: b, alpha: a)

	}
	 func getCenterColor() -> UIColor {//returns center pixel color value
		let height = self.size.height
		let width = self.size.width
		let centerY = height/2
		let centerX = width/2
		let center: CGPoint = CGPoint(x: centerX, y: centerY)
		return self.getPixelColor(pos: center)
	}
		/// Save PNG in the Documents directory
		func save(_ name: String) -> String {
			let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
			let url = URL(fileURLWithPath: path).appendingPathComponent(name)
			try! self.pngData()?.write(to: url)
			print("saved image at \(url.description)")
			return url.description
		}
	

}
extension UIColor {
    var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )

        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }

        return color
    }
}
