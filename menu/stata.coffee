'menu': [
  {
    'label': 'Packages'
    'submenu': [
      'label': 'stata-exec'
      'submenu': [
        { 'label': 'Send line/selection', 'command': 'stata-exec:send-lines'}
        { 'label': 'Send function', 'command': 'stata-exec:send-dofile'}
        'label': 'Change app'
        'submenu': [
          { 'label': 'StataMP', 'command': 'stata-exec:set-statamp'}
          { 'label': 'Stata', 'command': 'stata-exec:set-stata'}
        ]
      ]
    ]
  }
]
