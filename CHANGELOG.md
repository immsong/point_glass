## 1.1.0

* Added polygon line color support with customizable lineColor and lineAlpha properties
* Enhanced annual sector display with inner/outer line visibility controls (showInnerLine, showOuterLine)
* Refactored platform detection to use universal_platform package (removed dart:io dependency)

## 1.0.1

* Fixed README documentation with correct API usage
* Updated usage examples to match actual implementation

## 1.0.0

* Breaking changes: Transform3D class removed and replaced with PinholeCamera architecture
* Performance optimization: Added matrix caching system for real-time rendering
* Fixed PointGlassAnnualSectorPainter crash with empty lists
* Improved 3D graphics pipeline with standard architecture
* Enhanced code maintainability and stability

## 0.0.1

* Initial release
* 3D point cloud visualization with interactive features
* Interactive grid with customizable size, step, and labels
* Configurable coordinate axes with adjustable length
* Polygon creation and editing with customizable styling
* Annual sector display with angle and radius controls
* Multiple interaction modes (rotate, translate, spin, edit polygon)
* Cross-platform support (mobile, desktop, web)
* Customizable colors, transparency, and visual properties
* Real-time 3D transformation with ValueNotifier