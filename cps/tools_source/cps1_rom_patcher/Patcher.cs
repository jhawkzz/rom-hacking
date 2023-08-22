namespace cps1_rom_patcher
{
    internal static class Patcher
    {
        private const string CHUNK_DIRECTIVE_KEY = ";chunk";
        private const string BUILD_DATA_DIR = "\\build_data";

        public static List<string> PatchBuildOutputText { get; private set; } = new List<string>();

        public static void PatchRom( string binPath,
                                     string romsetPath,
                                     List<string> programRomList,
                                     string sourcePath,
                                     string patchedRomOutputPath )
        {
            // clean any data from the last run
            Console.WriteLine( "-=-=-=-=-CLEANING OUTPUT DIR-=-=-=-=-" );
            if ( Directory.Exists( sourcePath + BUILD_DATA_DIR ) )
            {
                CleanDirectory( sourcePath + BUILD_DATA_DIR );
            }

            // split source files into chunks
            FilesToChunks( sourcePath );

            // load each chunk and read the offset
            List<KeyValuePair<string, string>> chunkSourceFileByteOffsetPairs = new List<KeyValuePair<string, string>>();

            GetOffsetsForChunks( chunkSourceFileByteOffsetPairs, sourcePath );

            WriteFullProgramRom( binPath, romsetPath, programRomList, sourcePath, chunkSourceFileByteOffsetPairs, patchedRomOutputPath );
        }

        public static void FilesToChunks( string sourcePath )
        {
            Console.WriteLine( "-=-=-=-=-SPLITTING X68 FILES INTO CHUNKS-=-=-=-=-" );

            // for each x68 file we find, split it into multiple files with each SPLIT_KEY found
            // in the file.
            var newDir = Directory.CreateDirectory( sourcePath + BUILD_DATA_DIR );

            var filesFound = Directory.EnumerateFiles( sourcePath, "*.x68" );
            foreach ( var file in filesFound )
            {
                // get just the filename itself (strip path and extension)
                string fileName = file.Substring( file.LastIndexOf( '\\' ) + 1 );
                fileName = fileName.Substring( 0, fileName.LastIndexOf( '.' ) );

                Console.WriteLine( "Processing {0}", file );

                int numChunks = 0;

                using ( StreamReader sr = new StreamReader( file ) )
                {
                    while ( WriteChunk( sr, newDir + "\\" + fileName + numChunks + ".x68" ) )
                    {
                        Console.WriteLine( "Wrote Chunk: {0}", newDir + "\\" + fileName + numChunks + ".x68" );
                        numChunks++;
                    }
                }
            }
        }

        private static bool WriteChunk( StreamReader currFileSr, string chunkFileName )
        {
            bool foundChunkDirective = false;

            // make sure that there's still file content left.
            // This would fail if there's a ;break at the end of the last chunk.
            string? lineOfText = currFileSr.ReadLine();
            if ( lineOfText != null )
            {
                using ( StreamWriter streamWriter = new StreamWriter( chunkFileName ) )
                {
                    while ( lineOfText != null )
                    {
                        // treat any reference of ;break as a key to split
                        if ( lineOfText.ToLower().Contains( CHUNK_DIRECTIVE_KEY ) == false )
                        {
                            streamWriter.WriteLine( lineOfText );
                        }
                        // stop so the next chunk can be processed
                        else
                        {
                            foundChunkDirective = true;
                            break;
                        }

                        lineOfText = currFileSr.ReadLine();
                    }

                    streamWriter.Close();
                }
            }
            return foundChunkDirective;
        }

        private static void WriteFullProgramRom( string binPath,
                                                 string romsetPath,
                                                 List<string> programRomList,
                                                 string sourcePath,
                                                 List<KeyValuePair<string, string>> chunkFileByteOffsetPairs,
                                                 string patchedRomOutputPath )
        {
            Console.WriteLine( "-=-=-=-=-PATCHING ROM-=-=-=-=-" );

            // set the path up for our merged rom (the bin to which we'll actually apply our patches)
            string mergedRomName = "mergedRom.bin";
            string patchedRomWorkingDir = sourcePath + BUILD_DATA_DIR + "\\patched_rom";
            string mergedRomFilePath = patchedRomWorkingDir + "\\" + mergedRomName;

            // use 7zip to open the romset
            Console.WriteLine( "1. Unpacking romset {0}", romsetPath );
            var p = new System.Diagnostics.Process();
            p.StartInfo.FileName = binPath + "\\7-Zip\\7z.exe";
            p.StartInfo.Arguments = "x " + romsetPath + " " + "-o" + patchedRomWorkingDir;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.CreateNoWindow = true;
            p.Start();
            p.WaitForExit();
            Console.WriteLine( "7Zip: " + p.StandardOutput.ReadToEnd() );

            // use copy to concatenate the binary roms
            Console.WriteLine( "2. Creating merged rom" );
            p = new System.Diagnostics.Process();
            p.StartInfo.FileName = "cmd.exe";
            p.StartInfo.Arguments = "/C copy ";
            foreach ( var rom in programRomList )
            {
                p.StartInfo.Arguments += patchedRomWorkingDir + "\\" + rom + " " + "/B + ";
            }
            p.StartInfo.Arguments = p.StartInfo.Arguments.Substring( 0, p.StartInfo.Arguments.Length - 2 );
            p.StartInfo.Arguments += mergedRomFilePath;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.CreateNoWindow = true;
            p.Start();
            p.WaitForExit();
            Console.WriteLine( "copy: " + p.StandardOutput.ReadToEnd() );

            Console.WriteLine( "3. Assembling x68 files and applying them" );
            foreach ( var file in chunkFileByteOffsetPairs )
            {
                // Assemble file via LEA
                // lea requires a projName, so use the name of each file
                var projName = file.Key.Substring( file.Key.LastIndexOf( '\\' ) + 1 );
                Console.WriteLine( "Assembling {0}", projName );
                p = new System.Diagnostics.Process();
                p.StartInfo.FileName = binPath + "\\LEA\\LEA.exe";
                // O=B1 means plain binary, /W means Generate whole program listing, /Z means optimize and is NO/False, /Q means dont optimize math asm, /p is the project name.
                p.StartInfo.Arguments = "/O=B1 /W=true /Z=false /Q=false /P=" + projName + " " + file.Key;
                p.StartInfo.RedirectStandardOutput = true;
                p.StartInfo.UseShellExecute = false;
                p.StartInfo.CreateNoWindow = true;
                p.Start();
                p.WaitForExit();
                Console.WriteLine( "LEA: " + p.StandardOutput.ReadToEnd() );

                // byte swap the assembled bin
                Console.WriteLine( "Byteswapping {0}", projName );
                var leaOutputDir = sourcePath + BUILD_DATA_DIR + "\\Output";
                var binFileName = file.Key.Substring( file.Key.LastIndexOf( "\\" ) );
                var x68BinFilePath = leaOutputDir + binFileName + ".bin";

                p = new System.Diagnostics.Process();
                p.StartInfo.FileName = binPath + "\\byteswap.exe";
                p.StartInfo.Arguments = x68BinFilePath;
                p.StartInfo.RedirectStandardOutput = true;
                p.StartInfo.UseShellExecute = false;
                p.StartInfo.CreateNoWindow = true;
                p.Start();
                p.WaitForExit();
                Console.WriteLine( "Byteswap: " + p.StandardOutput.ReadToEnd() );

                // patch the rom
                Console.WriteLine( "Applying {0} to merged rom", projName );
                p = new System.Diagnostics.Process();
                p.StartInfo.FileName = binPath + "\\binpatch.exe";
                p.StartInfo.Arguments = mergedRomFilePath + " " + file.Value + " " + x68BinFilePath;
                p.StartInfo.RedirectStandardOutput = true;
                p.StartInfo.UseShellExecute = false;
                p.StartInfo.CreateNoWindow = true;
                p.Start();
                p.WaitForExit();
                Console.WriteLine( "Binpatch: " + p.StandardOutput.ReadToEnd() );
            }

            // delete the program roms we just merged so that we can split the merged rom back into them.
            Console.WriteLine( "4. Deleting original program roms" );
            foreach ( var rom in programRomList )
            {
                var romFilePath = patchedRomWorkingDir + "\\" + rom;

                Console.WriteLine( "Deleting original rom {0}", romFilePath );
                File.SetAttributes( romFilePath, FileAttributes.Normal );
                File.Delete( romFilePath );
            }

            // split the merged rom back out
            Console.WriteLine( "5. Splitting merged rom back to original rom files (but now patched)" );
            // NOTE: I don't know enough about CPS1 to say whether its safe to assume all program roms are 512kb
            // but for Knights it works.
            const int partitionSize = 512 * 1024;
            // patch the rom
            p = new System.Diagnostics.Process();
            p.StartInfo.FileName = binPath + "\\binsplit.exe";
            p.StartInfo.Arguments = mergedRomFilePath + " " + partitionSize;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.CreateNoWindow = true;
            p.Start();
            p.WaitForExit();
            Console.WriteLine( "Binsplit: " + p.StandardOutput.ReadToEnd() );

            // the files were broken out in the same order they were merged
            // so rename them accordingly
            // delete the program roms we just merged so that we can split the merged rom back into them.
            for ( int i = 0; i < programRomList.Count; i++ )
            {
                var romFilePath = patchedRomWorkingDir + "\\" + programRomList[i];

                string splitRomName = string.Format( "{0}_{1:D1}", mergedRomFilePath, i + 1 );

                Console.WriteLine( "Renaming {0} to {1}", splitRomName, romFilePath );
                File.Move( splitRomName, romFilePath );
            }

            // delete the mergedRom; we're done with it
            Console.WriteLine( "Deleting merged rom" );
            File.SetAttributes( mergedRomFilePath, FileAttributes.Normal );
            File.Delete( mergedRomFilePath );

            // at long last, zip up the new rom
            Console.WriteLine( "6. Packing patched rom into romset: " + patchedRomOutputPath );
            p = new System.Diagnostics.Process();
            p.StartInfo.FileName = binPath + "\\7-Zip\\7z.exe";
            p.StartInfo.Arguments = "a " + patchedRomOutputPath + " " + patchedRomWorkingDir + "\\*";
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.CreateNoWindow = true;
            p.Start();
            p.WaitForExit();
            Console.WriteLine( "7Zip: " + p.StandardOutput.ReadToEnd() );
        }

        private static void GetOffsetsForChunks( List<KeyValuePair<string, string>> chunksWithOffsets, string sourcePath )
        {
            Console.WriteLine( "-=-=-=-=-CALCULATING ROM OFFSETS FOR CHUNKS-=-=-=-=-" );

            var filesFound = Directory.EnumerateFiles( sourcePath + BUILD_DATA_DIR, "*.x68" );
            foreach ( var file in filesFound )
            {
                int orgWordsFoundThisFile = 0;
                int offsetVal = -1;

                // Parse each file for its 'org' value
                using ( StreamReader rs = new StreamReader( file ) )
                {
                    // go one line at a time
                    string? lineOfText = rs.ReadLine();
                    while ( lineOfText != null )
                    {
                        // see if this line HAS the word org, and that the word isn't part of a comment
                        int orgIndex = lineOfText.IndexOf( "org" );
                        int commentIndex = lineOfText.IndexOf( ';' );
                        if ( orgIndex > -1 && ( commentIndex == -1 || orgIndex < commentIndex ) )
                        {
                            // find it and read the value after as an int. If we can't, we won't count it.
                            string[] words = lineOfText.ToLower().Split( ' ' );
                            for ( int i = 0; i < words.Length - 1; i++ )
                            {
                                if ( words[i] == "org" )
                                {
                                    string offsetAsHex = words[i + 1].Substring( 1 ); //skip the $
                                    try
                                    {
                                        offsetVal = Convert.ToInt32( offsetAsHex, 16 );
                                        orgWordsFoundThisFile++;
                                    }
                                    catch ( System.FormatException )
                                    {
                                    }

                                }
                            }
                        }
                        lineOfText = rs.ReadLine();
                    }
                }

                if ( orgWordsFoundThisFile == 1 )
                {
                    chunksWithOffsets.Add( new KeyValuePair<string, string>( file, offsetVal.ToString() ) );
                }
                else if ( orgWordsFoundThisFile > 1 )
                {
                    // log a warning if there was more than 1 org directive found
                    Console.WriteLine( "WARNING: " + file + " contained multiple org directives." );
                }
                else
                {
                    // log that this file contained NO org word
                    Console.WriteLine( "WARNING: " + file + " contained no org directives." );
                }
            }
        }

        private static void CleanDirectory( string dirPath )
        {
            foreach ( var file in Directory.GetFiles( dirPath ) )
            {
                File.SetAttributes( file, FileAttributes.Normal );
                File.Delete( file );
            }

            foreach ( var dir in Directory.GetDirectories( dirPath ) )
            {
                CleanDirectory( dir );
            }
        }
    }
}

