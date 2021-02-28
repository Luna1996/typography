import bumpy, chroma, pixie, print, tables, typography, vmath, os, osproc,
  typography/svgfont, common

setCurrentDir(getCurrentDir() / "tests")

proc magnifyNearest*(image: Image, scale: int): Image =
  ## Scales image image up by an integer scale.
  result = newImage(
    image.width * scale,
    image.height * scale,
  )
  for y in 0 ..< result.height:
    for x in 0 ..< result.width:
      var rgba =
        image.getRgbaUnsafe(x div scale, y div scale)
      result.setRgbaUnsafe(x, y, rgba)

proc outlineBorder*(image: Image, borderPx: int): Image =
  ## Adds n pixel border around alpha parts of the image.
  result = newImage(
    image.width + borderPx * 2,
    image.height + borderPx * 3
  )
  for y in 0 ..< result.height:
    for x in 0 ..< result.width:
      var filled = false
      for bx in -borderPx .. borderPx:
        for by in -borderPx .. borderPx:
          var rgba = image[x + bx - borderPx, y - by - borderPx]
          if rgba.a > 0.uint8:
            filled = true
            break
        if filled:
          break
      if filled:
        result.setRgbaUnsafe(x, y, rgba(255, 255, 255, 255))

block:
  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 100
  var image = font.getGlyphImage("h")
  image.alphaToBlackAndWhite()
  image.writeFile("rendered/hFill.png")

block:
  var image = newImage(500, 40)
  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 16
  font.lineHeight = 16
  font.drawText(image, vec2(10, 10), "The \"quick\" brown fox jumps over the lazy dog.")

  image.alphaToBlackAndWhite()
  image.writeFile("rendered/basicSvg.png")

block:
  var font = readFontTtf("fonts/Ubuntu.ttf")
  font.size = 16
  var image = newImage(500, 40)

  font.drawText(image, vec2(10, 10), "The \"quick\" brown fox jumps over the lazy dog.")

  image.alphaToBlackAndWhite()
  image.writeFile("rendered/basicTtf.png")

block:
  var font = readFontTtf("fonts/IBMPlexSans-Regular.ttf")
  font.size = 16
  var image = newImage(500, 40)

  font.drawText(image, vec2(10, 10), "The \"quick\" brown fox jumps over the lazy dog.")

  image.alphaToBlackAndWhite()
  image.writeFile("rendered/basicTtf2.png")


block:
  var font = readFontSvg("fonts/Ubuntu.svg")
  var image = newImage(500, 240)

  font.size = 8
  font.drawText(image, vec2(10, 10), "The quick brown fox jumps over the lazy dog.")
  font.size = 10
  font.drawText(image, vec2(10, 25), "The quick brown fox jumps over the lazy dog.")
  font.size = 14
  font.drawText(image, vec2(10, 45), "The quick brown fox jumps over the lazy dog.")
  font.size = 22
  font.drawText(image, vec2(10, 75), "The quick brown fox jumps over the lazy dog.")
  font.size = 36
  font.drawText(image, vec2(10, 110), "The quick brown fox jumps over the lazy dog.")
  font.size = 72
  font.drawText(image, vec2(10, 180), "The quick brown fox jumps over the lazy dog.")

  image.alphaToBlackAndWhite()
  image.writeFile("rendered/sizes.png")

block:
  var image = newImage(800, 220)
  var font = readFontSvg("fonts/DejaVuSans.svg")

  font.size = 16
  font.lineHeight = 20
  font.drawText(image, vec2(10, 10), readFile("samples/sample.ru.txt"))

  image.alphaToBlackAndWhite()
  image.writeFile("rendered/ru.png")

block:
  var image = newImage(800, 200)
  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 16
  font.lineHeight = 20
  print "svg:", font.typeface.ascent, font.typeface.descent, font.typeface.unitsPerEm
  font.drawText(image, vec2(10, 10), readFile("samples/sample.txt"))
  image.alphaToBlackAndWhite()
  image.writeFile("rendered/sample_svg.png")

block:
  var image = newImage(800, 200)
  var font = readFontTtf("fonts/Ubuntu.ttf")
  font.size = 16
  font.lineHeight = 20
  print "ttf:", font.typeface.ascent, font.typeface.descent, font.typeface.unitsPerEm
  font.drawText(image, vec2(10, 10), readFile("samples/sample.txt"))
  image.alphaToBlackAndWhite()
  image.writeFile("rendered/sample_ttf.png")

# block:
#   var image = newImage(800, 200)
#   var font = readFontOtf("fonts/Ubuntu.ttf")

#   font.size = 16
#   font.lineHeight = 20
#   font.drawText(image, vec2(10, 10), readFile("samples/sample.txt"))

#   image.alphaToBlackAndWhite()
#   image.writeFile("otf.png")

block:
  var image = newImage(600, 620)
  var font = readFontTtf("fonts/hanazono/HanaMinA.ttf")
  font.size = 16
  font.lineHeight = 20

  font.drawText(image, vec2(10, 10), readFile("samples/sample.ch.txt"))

  image.alphaToBlackAndWhite()
  image.writeFile("rendered/ch.png")

block:
  var image = newImage(250, 20)

  var font = readFontSvg("fonts/DejaVuSans.svg")
  font.size = 11 # 11px or 8pt
  font.drawText(image, vec2(10, 4), "The quick brown fox jumps over the lazy dog.")

  image = image.magnifyNearest(4)
  image.alphaToBlackAndWhite()
  image.writeFile("rendered/scaledup.png")

block:
  var image = newImage(140, 20)

  var font = readFontSvg("fonts/DejaVuSans.svg")
  font.size = 11 # 11px or 8pt
  font.drawText(image, vec2(8, 4), "momomomomomomo")

  image = image.magnifyNearest(6)
  image.alphaToBlackAndWhite()
  image.writeFile("rendered/subpixelpos.png")

block:
  var image = newImage(140, 20)

  var font = readFontSvg("fonts/DejaVuSans.svg")
  font.size = 11 # 11px or 8pt
  var glyph = font.typeface.glyphs["g"]

  for i in 0 ..< 10:
    var glyphOffset: Vec2
    var at = vec2(12.0 + float(i)*12, 11)
    var glyphImage = font.getGlyphImage(
      glyph,
      glyphOffset,
      quality = 4,
      subPixelShift = float(i)/10.0
    )
    image.draw(
      glyphImage,
      at + glyphOffset
    )

  let mag = 6.0
  image = image.magnifyNearest(mag.int)
  for i in 0..<10:
    let at = vec2(12.0 + float(i)*12, 15) * mag
    font.drawText(image, at + vec2(0, 6), "+0." & $i)

  image.alphaToBlackAndWhite()

  let red = rgba(255, 0, 0, 255)
  for i in 0..<10:
    let at = vec2(12.0 + float(i)*12, 15) * mag
    image.strokeRectInner(rect(at + vec2(0, -13 * mag), vec2(7 * mag, 13 * mag)), red)

  image.writeFile("rendered/subpixelglyphs.png")

block:
  var font = readFontTtf("fonts/Moon Bold.otf")
  font.size = 300
  font.lineHeight = 300

  var image = font.getGlyphOutlineImage("Q")

  echo font.typeface.glyphs["Q"].pathStr

  image.writeFile("rendered/qOutLine.png")

  image = font.getGlyphImage("Q")
  image.alphaToBlackAndWhite()
  image.writeFile("rendered/qFill.png")

block:
  var image = newImage(200, 100)

  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 11 # 11px or 8pt
  font.lineHeight = 20

  # compute layout
  var layout = font.typeset("""
Two roads diverged in a yellow wood,
And sorry I could not travel both
And be one traveler, long I stood
And looked down one as far as I could
To where it bent in the undergrowth;""")

  echo "textBounds: ", layout.textBounds()

  # draw text at a layout
  image.drawText(layout)

  let mag = 3.0
  image = image.magnifyNearest(mag.int)
  image.alphaToBlackAndWhite()

  # draw layout boxes
  for pos in layout:
    var font = pos.font
    if pos.character in font.typeface.glyphs:
      var glyph = font.typeface.glyphs[pos.character]
      var glyphOffset: Vec2
      let img = font.getGlyphImage(
        glyph,
        glyphOffset,
        subPixelShift = pos.subPixelShift
      )
      image.strokeRectInner(
        rect(
          (pos.rect.xy + glyphOffset) * mag,
          vec2(float img.width, float img.height) * mag
        ),
        rgba(255, 0, 0, 255)
      )
  image.writeFile("rendered/layout.png")

  image.fill(rgba(255, 255, 255, 255))
  # draw layout boxes only
  for pos in layout:
    var font = pos.font
    if pos.character in font.typeface.glyphs:
      var glyph = font.typeface.glyphs[pos.character]
      var glyphOffset: Vec2
      let img = font.getGlyphImage(
        glyph,
        glyphOffset,
        subPixelShift = pos.subPixelShift
      )
      image.strokeRectInner(
        rect(
          (pos.rect.xy + glyphOffset) * mag,
          vec2(float img.width, float img.height) * mag
        ),
        rgba(255, 0, 0, 255)
      )
  image.writeFile("rendered/layoutNoText.png")

block:
  var image = newImage(500, 200)

  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 11 # 11px or 8pt
  font.lineHeight = 11

  image.drawText(
    font.typeset(
      "Left, Top",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Left,
      vAlign = Top
    )
  )
  image.drawText(
    font.typeset(
      "Left, Middle",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Left,
      vAlign = Middle
    )
  )
  image.drawText(
    font.typeset(
      "Left, Bottom",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Left,
      vAlign = Bottom
    )
  )

  image.drawText(
    font.typeset(
      "Center, Top",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Center,
      vAlign = Top
    )
  )
  image.drawText(
    font.typeset(
      "Center, Middle",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Center,
      vAlign = Middle
    )
  )
  image.drawText(
    font.typeset(
      "Center, Bottom",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Center,
      vAlign = Bottom
    )
  )

  image.drawText(
    font.typeset(
      "Right, Top",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Right,
      vAlign = Top
    )
  )
  image.drawText(
    font.typeset(
      "Right, Middle",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Right,
      vAlign = Middle
    )
  )
  image.drawText(
    font.typeset(
      "Right, Bottom",
      pos = vec2(20, 20),
      size = vec2(460, 160),
      hAlign = Right,
      vAlign = Bottom
    )
  )

  image.alphaToBlackAndWhite()

  image.strokeRectInner(
    rect(20, 20, 460, 160),
    rgba(255, 0, 0, 255)
  )

  image.writeFile("rendered/alignment.png")

block:
  var image = newImage(500, 200)

  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 16
  font.lineHeight = 20

  image.drawText(font.typeset(
    readFile("samples/sample.wrap.txt"),
    pos = vec2(100, 20),
    size = vec2(300, 160)
  ))

  image.alphaToBlackAndWhite()

  image.strokeRectInner(
    rect(100, 20, 300, 160),
    rgba(255, 0, 0, 255)
  )

  image.writeFile("rendered/wordwrap.png")

block:
  var image = newImage(500, 200)

  var font = readFontTtf("fonts/hanazono/HanaMinA.ttf")
  font.size = 16
  font.lineHeight = 20

  image.drawText(font.typeset(
    readFile("samples/sample.ch.txt"),
    pos = vec2(100, 20),
    size = vec2(300, 160)
  ))

  image.alphaToBlackAndWhite()

  image.strokeRectInner(
    rect(100, 20, 300, 160),
    rgba(255, 0, 0, 255)
  )

  image.writeFile("rendered/wordwrapch.png")

block:
  var image = newImage(300, 120)

  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 16 # 11px or 8pt
  font.lineHeight = 20

  # compute layout
  var layout = font.typeset("""
Two roads diverged in a yellow wood,
And sorry I could not travel both
And be one traveler, long I stood
And looked down one as far as I could
To where it bent in the undergrowth;""",
  vec2(10, 10))

  # draw text at a layout
  image.drawText(layout)

  image.alphaToBlackAndWhite()

  let selectionRects = layout.getSelection(23, 120)
  # draw selection boxes
  for rect in selectionRects:
    image.strokeRectInner(rect, rgba(255, 0, 0, 255))

  image.writeFile("rendered/selection.png")

block:

  var image = newImage(300, 120)

  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 16
  font.lineHeight = 20

  # compute layout
  var layout = font.typeset("""
Two roads diverged in a yellow wood,
And sorry I could not travel both
And be one traveler, long I stood
And looked down one as far as I could
To where it bent in the undergrowth;""",
  vec2(10, 10))

  # draw text at a layout
  image.drawText(layout)

  image.alphaToBlackAndWhite()

  let at = vec2(120, 52)
  let g = layout.pickGlyphAt(at)
  # draw g
  image.strokeRectInner(rect(at, vec2(4, 4)), rgba(0, 0, 255, 255))
  image.strokeRectInner(g.selectRect, rgba(255, 0, 0, 255))

  image.writeFile("rendered/picking.png")

block:
  var image = newImage(500, 120)

  var font = readFontSvg("fonts/Ubuntu.svg")
  font.size = 16
  font.lineHeight = 20

  # compute layout
  var layout = font.typeset(
    "name\tstate\tnumber\tcount\n" &
    "cat\tT\t3.14\t0\n" &
    "dog\tF\t2.11\t1\n" &
    "really loong cat\tG\t123.678\t2",
    vec2(10, 10),
    tabWidth = 100)

  # draw text at a layout
  image.drawText(layout)
  image.alphaToBlackAndWhite()
  image.writeFile("rendered/tabs.png")

block:

  var mainFont = readFontTtf("fonts/Ubuntu.ttf")

  var image = newImage(1200, 400)
  var y = 10.0
  for fontPath in [
    "fonts/Jura-Regular.ttf",
    "fonts/IBMPlexSans-Regular.ttf",
    "fonts/silver.ttf",
    "fonts/Ubuntu.ttf",
    "fonts/Lato-Regular.ttf",
    "fonts/SourceSansPro-Regular.ttf",
    "fonts/Changa-Bold.ttf"
  ]:
    mainFont.size = 10
    mainFont.lineHeight = 32
    mainFont.drawText(image, vec2(10, y), fontPath.lastPathPart)

    var x = 150.0
    var font = readFontTtf(fontPath)
    print font.typeface.name, font.typeface.ascent, font.typeface.descent, font.typeface.xHeight, font.typeface.capHeight
    for s in [8, 12, 16, 18, 20, 32]:
      font.size = s.float
      font.lineHeight = 32

      let fontHeight = font.typeface.ascent - font.typeface.descent
      print fontHeight / font.size , font.typeface.unitsPerEm / font.size
      # print font.ascent * scale, font.descent * scale
      font.drawText(image, vec2(x, y), "Figte")
      image.strokeRectInner(rect(x, y, 100, 32), rgba(255, 255, 255, 255))

      x += 150

    y += 50

let (outp, _) = execCmdEx("git diff tests/rendered/*.png")
if len(outp) != 0:
  echo outp
  quit("Output does not match")
