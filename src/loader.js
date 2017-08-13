/* eslint-disable no-eval */

function es6Support() {
  if ('Map' in window &&
      'Symbol' in window &&
      'includes' in Array.prototype) {
    try {
      eval('class A{}')
      eval('(function a(a=1){})')
      eval('(function a(...a){})')
      eval('for (let i of []){}')
      eval('``')
      eval('const [a,b]=[0,0]')
      eval('(()=>0)')
      return true
    } catch (e) {
      if (e.name !== 'SyntaxError') {
        throw e
      }
    }
  }
  return false
}

const script = document.createElement('script')
script.src = (es6Support() ? 'starshape.js' : 'starshape.es5.js')
document.head.appendChild(script)
