// See https://aka.ms/new-console-template for more information
using cps1_rom_patcher;

//BUG: Paths cannot have spaces (7zip limitation)
//BUG: Process output capturing isnt getting all stdio
//BUG: There are crashes if files are specified but missing.

bool argsValid = true;

string? binToolsPath = GetValueForArg( "-bintools", args );
if ( binToolsPath == null )
{
    argsValid = false;
    Console.WriteLine( "Arg -bintools missing. Where are the dependency bins?" );
    Console.WriteLine( "Need 7Zip, LEA, binswap, binpatch and binsplit" );
    Console.WriteLine( "" );
}

string? sourceRomsetFilePath = GetValueForArg( "-game", args );
if ( sourceRomsetFilePath == null )
{
    argsValid = false;
    Console.WriteLine( "Arg -game missing. What game is being patched?" );
    Console.WriteLine( "Need path to romset .zip file. Ex: C:\\roms\\knights.zip" );
    Console.WriteLine( "" );
}

string? romList = GetValueForArg( "-roms", args );
if ( romList == null )
{
    argsValid = false;
    Console.WriteLine( "Arg -roms missing. What program roms are being patched? (The specific rom files in the romset .zip)" );
    Console.WriteLine( "Provide as a comma delimited list. Ex: -roms kr_23e.8f,kr_22.7f" );
    Console.WriteLine( "***THE ORDER OF THESE PROGRAM ROMS MATTER. THEY MUST BE IN ASSEMBLED ORDER***" );
    Console.WriteLine( "" );
}

string? x68SourceDirPath = GetValueForArg( "-x68source", args );
if ( x68SourceDirPath == null )
{
    argsValid = false;
    Console.WriteLine( "Arg -x68source missing. What x68 source files are being applied to the game?" );
    Console.WriteLine( "Need path to folder containing source files. Ex: C:\\hacking\\source" );
    Console.WriteLine( "" );
}

string? destRomsetOutputFile = GetValueForArg( "-output", args );
if ( destRomsetOutputFile == null )
{
    argsValid = false;
    Console.WriteLine( "Arg -output missing. Where is the patched game romset being saved?" );
    Console.WriteLine( "Ex: C:\\knights-hacked.zip" );
    Console.WriteLine( "" );
}

if ( argsValid )
{
    Patcher.PatchRom( binToolsPath,
                      sourceRomsetFilePath,
                      romList.Split( ',' ).ToList(),
                      x68SourceDirPath,
                      destRomsetOutputFile );

    Console.WriteLine( "-=-=-=-=-COMPLETE-=-=-=-=-" );
}
else
{
    Console.WriteLine( "Please fix args and try again." );
}

string? GetValueForArg( string targetArg, string[] args )
{
    for ( int i = 0; i < args.Length - 1; i++ )
    {
        if ( args[i].ToLower() == targetArg )
        {
            return args[i + 1];
        }
    }

    return null;
}