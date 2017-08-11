# SwiftMiniProjects
![Banner](./Banner.png)

Inspired by the many "30 Swift Projects" I thought it best to break create a single workspace and repo for all mini projects I start. These are not projects focused on building an app but rather classes built to be easily integratable with future apps.

## Contents

### UIDrawerController

```swift
let drawer = UIDrawerController(centerViewController: UINavigationController(rootViewController: centerVC), leftViewController: leftVC, rightViewController: rightVC)
```

### UIPageTabBarController

```swift
let pageVC = UIPageTabBarController(viewControllers: viewControllers)
pageVC.tabBarPosition = .bottom // Top or Bottom
pageVC.tabBarEdgeInsets.top = 20
pageVC.tabBarHeight = 22
pageVC.tabBarItemWidth = 100 // Set the exact width you want or leave as 0 for auto-width
pageVC.currentTabLineHeight = 2.5
pageVC.currentTabLineColor = .green
pageVC.tabBar.tintColor = UIColor.black
```

### UIWebViewController

```swift
let vc = UIWebViewController(url: url)
vc.isUITranslucent = false
```

### UICollectionViewStretchyLayout
