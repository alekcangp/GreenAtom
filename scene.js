
	var canvas = document.querySelector("#scene"),
    ctxx = canvas.getContext("2d"),
    particles = [],
    amount = 0,
    mouse = {x:0,y:0},
    radius = 1;

var colors = ["#006400","#3CB371", "#00FA9A","#32CD32", "#0000CD"];

var copy = document.querySelector("#copy");

var ww = canvas.width = window.innerWidth;
var wh = canvas.height = window.innerHeight;

function Particle(x,y){
    this.x =  Math.random()*ww;
    this.y =  Math.random()*wh;
    this.dest = {
        x : x,
        y: y
    };
    this.r =  Math.random()*3 + 1;
    this.vx = (Math.random()-0.5)*20;
    this.vy = (Math.random()-0.5)*20;
    this.accX = 0;
    this.accY = 0;
    this.friction = Math.random()*0.02 + 0.95;

    this.color = colors[Math.floor(Math.random()*6)];
}

Particle.prototype.render = function() {


    this.accX = (this.dest.x - this.x)/1000;
    this.accY = (this.dest.y - this.y)/1000;
    this.vx += this.accX;
    this.vy += this.accY;
    this.vx *= this.friction;
    this.vy *= this.friction;

    this.x += this.vx;
    this.y +=  this.vy;

    ctxx.fillStyle = this.color;
    ctxx.beginPath();
    ctxx.arc(this.x, this.y, this.r, Math.PI * 2, false);
    ctxx.fill();

    var a = this.x - mouse.x;
    var b = this.y - mouse.y;

    var distance = Math.sqrt( a*a + b*b );
    if(distance<(radius*70)){
        this.accX = (this.x - mouse.x)/100;
        this.accY = (this.y - mouse.y)/100;
        this.vx += this.accX;
        this.vy += this.accY;
    }

}

function onMouseMove(e){
    mouse.x = e.clientX;
    mouse.y = e.clientY;
}

function onTouchMove(e){
if(e.touches.length > 0 ){
  mouse.x = e.touches[0].clientX;
  mouse.y = e.touches[0].clientY;
}
}

function onTouchEnd(e){
mouse.x = -9999;
mouse.y = -9999;
}

function initScene(){
    ww = canvas.width = window.innerWidth;
    wh = canvas.height = window.innerHeight;

    ctxx.clearRect(0, 0, canvas.width, canvas.height);

    ctxx.font = "bold 80px sans-serif";
    ctxx.textAlign = "center";
    ctxx.fillText(copy.value, ww/2+40, 80);

    var data  = ctxx.getImageData(0, 0, ww, wh).data;
    ctxx.clearRect(0, 0, canvas.width, canvas.height);
    ctxx.globalCompositeOperation = "screen";

    particles = [];
    for(var i=0;i<ww;i+=4){
        for(var j=0;j<wh;j+=4){
            if(data[ ((i + j*ww)*4) + 3] > 150){
                particles.push(new Particle(i,j));
            }
        }
    }
    amount = particles.length;

}

function onMouseClick(){
    radius++;
    if(radius ===5){
        radius = 0;
    }
}

function render(a) {
    requestAnimationFrame(render);
    ctxx.clearRect(0, 0, canvas.width, canvas.height);
    for (var i = 0; i < amount; i++) {
        particles[i].render();
    }
};

copy.addEventListener("keyup", initScene);
window.addEventListener("resize", initScene);
window.addEventListener("mousemove", onMouseMove);
window.addEventListener("touchmove", onTouchMove);
window.addEventListener("click", onMouseClick);
window.addEventListener("touchend", onTouchEnd);
initScene();
requestAnimationFrame(render);

