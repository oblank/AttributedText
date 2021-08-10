#if canImport(UIKit) && !os(watchOS)

    import SwiftUI
    import SafariServices
    import Lightbox

    @available(iOS 14.0, tvOS 14.0, macCatalyst 14.0, *)
    struct TextViewWrapper: UIViewRepresentable {
        final class View: UITextView {
            var maxLayoutWidth: CGFloat = 0 {
                didSet {
                    guard maxLayoutWidth != oldValue else { return }
                    invalidateIntrinsicContentSize()
                }
            }

            override var intrinsicContentSize: CGSize {
                guard maxLayoutWidth > 0 else {
                    return super.intrinsicContentSize
                }

                return sizeThatFits(
                    CGSize(width: maxLayoutWidth, height: .greatestFiniteMagnitude)
                )
            }
        }

        @available(iOSApplicationExtension, unavailable)
        final class Coordinator: NSObject, UITextViewDelegate {
            var openURL: OpenURLAction?
            
            func openURLbySF(_ urlString: String) {
                guard let url = URL(string: urlString) else {
                    // not a valid URL
                    return
                }
                if ["http", "https"].contains(url.scheme?.lowercased() ?? "") || urlString.hasPrefix("www."){
                    var window: UIWindow? = UIApplication.shared.windows.first
                    if UIApplication.shared.windows.count > 1 {
                        window = UIApplication.shared.windows[1]
                    }
                    if window == nil  {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                    let safariViewController = SFSafariViewController(url: url)
                    window?.rootViewController?.present(safariViewController, animated: true, completion: nil)
                } else {
                    // Scheme is not supported or no scheme is given, use openURL
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }

            func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
                self.openURLbySF(URL.absoluteString)
                
                // openURL?(URL)
                return false
            }
            
            func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
                let images = [
                  LightboxImage(image: textAttachment.image!)
                ]
                // Create an instance of LightboxController.
                let controller = LightboxController(images: images)
                // Use dynamic background.
                controller.dynamicBackground = true
                
                // Present your controller.
                var window: UIWindow? = UIApplication.shared.windows.first
                if UIApplication.shared.windows.count > 1 {
                    window = UIApplication.shared.windows[1]
                }
                // 从下向上推入展示
                let transition = CATransition()
                transition.duration = 0.2
                transition.type = CATransitionType.moveIn
                //transition.speed = 5
                transition.subtype = CATransitionSubtype.fromTop
                window?.rootViewController?.view.window?.layer.add(transition, forKey: kCATransition)
                window?.rootViewController?.present(controller, animated: true, completion: nil)
                
//                let navController = UINavigationController(rootViewController: controller)
//                window?.rootViewController?.present(navController, animated: true, completion: nil)
                
                return true
            }
        }

        let attributedText: NSAttributedString
        let maxLayoutWidth: CGFloat
        let textViewStore: TextViewStore

        func makeUIView(context: Context) -> View {
            let uiView = View()

            uiView.backgroundColor = .clear
            uiView.textContainerInset = .zero
            #if !os(tvOS)
                uiView.isEditable = false
            #endif
            uiView.isScrollEnabled = false
            uiView.textContainer.lineFragmentPadding = 0
            uiView.delegate = context.coordinator

            return uiView
        }

        func updateUIView(_ uiView: View, context: Context) {
            uiView.attributedText = attributedText
            uiView.maxLayoutWidth = maxLayoutWidth

            uiView.textContainer.maximumNumberOfLines = context.environment.lineLimit ?? 0
            uiView.textContainer.lineBreakMode = NSLineBreakMode(truncationMode: context.environment.truncationMode)

            context.coordinator.openURL = context.environment.openURL

            textViewStore.didUpdateTextView(uiView)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }
    }

#endif
