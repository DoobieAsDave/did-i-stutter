public class BPM 
{
    static dur note, halfNote, quarterNote, eighthNote, sixteenthNote, thirtiethNote;

    65377::samp => note;
    note / 2 => halfNote;
    halfNote / 2 => quarterNote;
    quarterNote / 2 => eighthNote;
    eighthNote / 2 => sixteenthNote;
    sixteenthNote / 2 => thirtiethNote;
}