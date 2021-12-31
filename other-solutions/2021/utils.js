getCurrentTime = () => {
    return new Date().getTime();
}

getDuration = ( startTime ) => {
    return ( getCurrentTime() - startTime );
}

module.exports = { getCurrentTime, getDuration };