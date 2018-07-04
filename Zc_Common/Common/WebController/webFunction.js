
// 以下Function都是对XT后台提供的HTML代码进行操作
function loadPlaceholderPhoto() {
    var objs = document.querySelectorAll('img')
    for(var i=0;i<objs.length;i++)
    {
        var img = objs[i]
        var src = img.getAttribute('src')
        img.setAttribute('u_src',src)
        img.setAttribute('u_sw',img.style.width)
        img.setAttribute('u_sh',img.style.height)
        img.setAttribute('u_w',img.width)
        img.setAttribute('u_h',img.height)
        img.removeAttribute('width')
        img.removeAttribute('height')
        var w = window.screen.width - 40
        img.style.width = w
        img.style.height = 0.4 * w
        img.src = 'http://hsej.app360.cn/images/webplaceholder.png'
    };
}

function loadRealPhoto() {
    var objs = document.querySelectorAll('img');
    for(var i=0; i<objs.length; i++)
    {
        var img = objs[i]
        var src = img.getAttribute('u_src')
        loadimg(img,src)
    };
}

function loadimg(img,src){
    var _img = new Image()
    _img.src = src
    _img.onload = function() {
        resizeImages(img,_img)
        img.src = src
        img.onload = function() {
            img.onclick = function() {
                document.location = 'myweb:imageClick:' + this.src
            }
            xt_changecontentheight()
            _img = null
        }
    }
} 

function resizeImages(img,_img) {
    var realwidth = _img.width
    var realheight = _img.height
    var maxwidth = window.screen.width - 35
   
    var u_w = img.getAttribute('u_w')
    var u_h = img.getAttribute('u_h')
    
    var u_sw = img.getAttribute('u_sw')
    var u_sh = img.getAttribute('u_sh')
    
    //var tem_w = max(u_w,u_sw)
    
    u_w = u_w > u_sw ? u_w : u_sw;
    
    if (u_w < maxwidth) {
        img.style.width = u_w
        img.style.height = (realheight * (u_w/realwidth))
    }
    else if(realwidth > maxwidth) {
        img.style.width = maxwidth
        img.style.height = (realheight * (maxwidth/realwidth))
    }
    else {
        img.style.width = realwidth
    }
};

function resizeimg (img) {
    var oldwidth = img.width
    var oldheight = img.height
    var maxwidth=window.screen.width - 27
    if(img.width > maxwidth) {
        img.style.width = maxwidth+'px'
        img.style.height = (oldheight * (maxwidth/oldwidth))+'px'
    }
}

function imgFunction () {
    var objs = document.getElementsByTagName('img')
    var imgScr = ''
    for (var i=0;i<objs.length;i++) {
        var img = objs[i];
        var src = img.getAttribute('src')
        imgScr = imgScr + src + '+'
        resizeimg(img)
        img.onclick = function() {
            document.location = 'myweb:imageClick:' + this.src
        }
    }
    xt_gethtmlimage(imgScr)
}

function consoleLog (string) {
    xt_consoleLog(string)
}

function placeHolderImg(){
    var imgs = document.getElementsByTagName('img');
    var cw = window.screen.width-20;
    //document.documentElement.clientWidth;
    for(var i = 0; i < imgs.length; i++){
        var width = imgs[i].style.width;
        var _src = imgs[i].src;
        var r = _src.match(/_\S+./g);
        if(r == null){
            return;
        }
        r = r[0].split('.')[0].replace('_','');
        var alt = r.split('x');
        var rWdith = parseInt(alt[0]);
        var rHeight = parseInt(alt[1]);
        if(width.indexOf('%') != -1){
            width = parseInt(width);
            width = cw * width / 100;
        }else if(width.indexOf('px') != -1){
            width = width.replace('px','');
        }else{
            width = 0;
        }
        console.log(width);
        if(width == '0' || width > cw ){
            if(rWdith > cw){
                imgs[i].style.width = cw + 'px';
                imgs[i].style.height = cw * rHeight / rWdith + 'px';
            }else{
                imgs[i].style.width = rWdith + 'px';
                imgs[i].style.height = rHeight + 'px';
            }
        }else{
            imgs[i].style.height = width * rHeight / rWdith + 'px';
        }
    }
}

placeHolderImg();

window.onload = function () {
    imgFunction()
    xt_changecontentheight()
}
