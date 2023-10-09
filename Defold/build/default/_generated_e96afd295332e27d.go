components {
  id: "main"
  component: "/main/main.script"
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
  property_decls {
  }
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "tile_set: \"/main/512x256/512x256.atlas\"\ndefault_animation: \"512x256\"\nmaterial: \"/builtins/materials/sprite.material\"\nblend_mode: BLEND_MODE_ALPHA\n"
  position {
    x: 256.0
    y: 112.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
  scale {
    x: 1.0
    y: -1.0
    z: 1.0
  }
}
embedded_components {
  id: "label1"
  type: "label"
  data: "size {\n  x: 320.0\n  y: 20.0\n  z: 0.0\n  w: 0.0\n}\ncolor {\n  x: 1.0\n  y: 1.0\n  z: 1.0\n  w: 1.0\n}\noutline {\n  x: 0.0\n  y: 0.0\n  z: 0.0\n  w: 1.0\n}\nshadow {\n  x: 0.0\n  y: 0.0\n  z: 0.0\n  w: 1.0\n}\nleading: 1.0\ntracking: 0.0\npivot: PIVOT_NW\nblend_mode: BLEND_MODE_ALPHA\nline_break: false\ntext: \"Label\"\nfont: \"/builtins/fonts/system_font.font\"\nmaterial: \"/builtins/fonts/label.material\"\n"
  position {
    x: 0.0
    y: 240.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "label2"
  type: "label"
  data: "size {\n  x: 320.0\n  y: 20.0\n  z: 0.0\n  w: 0.0\n}\ncolor {\n  x: 1.0\n  y: 1.0\n  z: 1.0\n  w: 1.0\n}\noutline {\n  x: 0.0\n  y: 0.0\n  z: 0.0\n  w: 1.0\n}\nshadow {\n  x: 0.0\n  y: 0.0\n  z: 0.0\n  w: 1.0\n}\nleading: 1.0\ntracking: 0.0\npivot: PIVOT_NW\nblend_mode: BLEND_MODE_ALPHA\nline_break: false\ntext: \"Label\"\nfont: \"/builtins/fonts/system_font.font\"\nmaterial: \"/builtins/fonts/label.material\"\n"
  position {
    x: 0.0
    y: 220.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
