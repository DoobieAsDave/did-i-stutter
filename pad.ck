BPM tempo;

Gain bus;
SinOsc oscSub => bus;
SawOsc osc1 => bus;
SawOsc osc2 => bus;
SawOsc osc3 => bus;
SawOsc osc4 => bus;
bus => LPF filter => ADSR adsr => Pan2 pan => dac;

SinOsc panLfo => blackhole;
SinOsc filterLfo => blackhole;

56 => int key;
0 => int chordIndex;
tempo.note => dur bar;
bar * 8 => dur beat;

1 => oscSub.gain;
.2 => osc1.gain => osc2.gain => osc3.gain => osc4.gain;

Std.mtof(key + 24) => filter.freq;

2 => filterLfo.freq;
2 => filterLfo.gain;
1 => panLfo.freq;

[
    [0, 4, 7, 11],
    [12, 4, 7, 11],
    [12, 4, 7, 17],
    [0, 4, 7, -1] 
] @=> int majorChords[][];
[
    [0, 3, 7, 10],
    [12, 3, 7, 10],
    [12, 3, 7, 15],
    [0, 3, 7, -2]
] @=> int minorChords[][];

function void trigger(int chordMode, dur duration) {
    (
        Math.random2f(150.0, 400.0)::ms, 
        Math.random2f(75.0, 150.0)::ms,
        Math.random2f(.4, .7), 
        300::ms
    ) => adsr.set;

    Std.mtof(key - 24) => oscSub.freq;

    if (chordMode) {
        //minorChords[chordIndex] @=> int chord[];
        //<<<chord[0], chord[1], chord[2], chord[3]>>>;
        //minorChords[0] @=> int chord[]; 
        minorChords[Math.random2(0, minorChords.cap() - 1)] @=> int chord[];        
        Std.mtof(chord[0] + key) => osc1.freq;
        Std.mtof(chord[1] + key) => osc2.freq;
        Std.mtof(chord[2] + key) => osc3.freq;
        Std.mtof(chord[3] + key) => osc4.freq;
    }
    else {
        //majorChords[chordIndex] @=> int chord[];
        //<<<chord[0], chord[1], chord[2], chord[3]>>>;       
        //majorChords[0] @=> int chord[]; 
        majorChords[Math.random2(0, majorChords.cap() - 1)] @=> int chord[]; 
        Std.mtof(chord[0] + key) => osc1.freq;
        Std.mtof(chord[1] + key) => osc2.freq;
        Std.mtof(chord[2] + key) => osc3.freq;
        Std.mtof(chord[3] + key) => osc4.freq;
    }

    1 => adsr.keyOn;
    duration - adsr.releaseTime() => now;

    1 => adsr.keyOff;
    adsr.releaseTime() => now;    
}

function void modPanLfo() {
    while(true) {
        (panLfo.last() / 4) + .2 => pan.pan;
        //<<<pan.pan()>>>;
        5::ms => now;
    }    
}

function void modFilterLfo() {
    while(true) {
        (((filterLfo.last() + 1) / 2) * 1000) + Std.mtof(key + 48) => filter.freq;
        //<<<filter.freq()>>>;
        5::ms => now;
    }
}

function void switchChords() {
    if (chordIndex < minorChords.cap() - 1) {
        chordIndex++;
    }
    else {
        0 => chordIndex;
    }    
}

spork ~ modPanLfo();
spork ~ modFilterLfo();

while(true) {
    56 - 5 => key;
    trigger(1, beat / 2);

    52 - 5 => key;
    trigger(1, beat / 2);

    switchChords();
}