BRF filter;
SndBuf buffer1 => filter => dac;
SndBuf buffer2 => filter => dac;

SinOsc filterLfo => blackhole;
SinOsc combLfo => blackhole;

dac => WvOut render => blackhole;
"did_i_stutter.wav" => render.wavFilename;

me.dir() + "break.wav" => buffer1.read => buffer2.read;
.75 => buffer1.gain => buffer2.gain;
0 => buffer1.pos => buffer2.pos;
Std.mtof(60) => filter.freq;
.4 => filter.Q;
.75 => filter.gain;

.075 => filterLfo.freq;
.05 => combLfo.freq;

float combDelay;
buffer1.length() / 4 => dur breakLength;
buffer1.samples() / 4 => int beats;

function void cut(int slice, dur duration) {    
    beats * slice => int position;

    trigger(buffer1, position, 0::samp);
    trigger(buffer2, position, combDelay::samp);    

    duration => now;
}

function void trigger(SndBuf buffer, int position, dur delay) {
    delay => now;
    position => buffer.pos;
}

function void modFilterLfo() {
    while(true) {
        (filterLfo.last() * 200) + Std.mtof(60) => filter.freq;
        //<<<filter.freq()>>>;
        5::ms => now;
    }
}

function void modCombLfo() {
    while(true) {
        ((combLfo.last() + 1) / 2) * 2 => combDelay;
        200 +=> combDelay;
        //<<<combDelay>>>;
        5::ms => now;
    }
}

//spork ~ modFilterLfo();
spork ~ modCombLfo();

function void original() {
    <<<"original">>>;
    cut(0, breakLength);
    cut(1, breakLength);
    cut(2, breakLength);
    cut(3, breakLength);
}

function void reversed() {
    <<<"reversed">>>;
    cut(3, breakLength);
    cut(2, breakLength);
    cut(1, breakLength);
    cut(0, breakLength);
}

function void partA() {
    <<<"A">>>;
    cut(0, (breakLength) / 3);
    cut(0, (breakLength) / 3);
    cut(0, (breakLength) / 3);
    cut(1, breakLength);
    cut(2, breakLength);
    cut(3, breakLength);
}

function void partB() {
    <<<"B">>>;
    cut(3, breakLength);
    cut(1, (breakLength) / 2);
    cut(1, (breakLength) / 2);
    cut(2, breakLength);
    cut(3, breakLength);
}

function void partC() {
    <<<"C">>>;
    cut(0, breakLength);
    cut(2, breakLength);
    cut(0, (breakLength) / 2);
    cut(2, (breakLength) / 2);
    cut(3, breakLength);
}

function void partD() {
    <<<"D">>>;
    cut(0, breakLength);
    cut(2, breakLength);
    cut(0, breakLength);
    cut(1, breakLength);
}

function void partE() {
    <<<"E">>>;
    cut(0, breakLength);    
    cut(1, (breakLength) / 2);
    cut(1, (breakLength) / 2);
    cut(2, breakLength);
    cut(3, breakLength);
}

function void partF() {
    <<<"F">>>;
    cut(0, breakLength);
    cut(1, breakLength);
    cut(2, breakLength);
    cut(3, (breakLength) / 2);
    cut(3, (breakLength) / 2);
}

function void experimental() {
    partC();
    partD();
    partC();
    partE();

    partD();
    partB();
    partA();
    partB();
}

while(true) {
    repeat(3) { original(); }
    partB();

    repeat(3) { original(); }
    partF();

    repeat(3) { original(); }
    partB();

    partA();
    original();
    partC();
    partB();
}