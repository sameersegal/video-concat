const concat = require('ffmpeg-concat')

// concat 3 mp4s together using 2 500ms directionalWipe transitions
const join = async function(){
    const result = await concat({
        output: 'joined.mp4',
        videos: [
            '../1.mp4',
            '../2.mp4',
            '../3.mp4'
        ],
        transition: {
            name: 'fade',
            duration: 500
        }
    }).catch((err) => console.log("ERROR", err));

    return result;
}

join();
