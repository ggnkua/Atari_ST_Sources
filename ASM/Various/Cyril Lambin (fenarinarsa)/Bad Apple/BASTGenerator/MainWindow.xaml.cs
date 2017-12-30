// Bad Apple Atari ST Generator
// by fenarinarsa (Cyril Lambin), 2017
//
// Takes a png sequence and converts it to a pi1/pi3 degas sequence
// Then converts the degas sequence into a delta-packed file for the badapple.tos "player"
// Compiled with Visual Studio Community 2015
//
// Copyright(C) 2017 Cyril Lambin
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.If not, see <https://www.gnu.org/licenses/>.
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Drawing;
using System.IO;
using System.ComponentModel;

namespace BASTGenerator
{

    public partial class MainWindow : Window
    {
        // What is this?
        // It's the C# program that generates data file for the badapple.tos Atari ST "player"
        //
        // What do I need?
        // Visual Studio Community 2015, vasm m68k and the assets available at https://fenarinarsa.com/badapple/fenarinarsa_badapple_source.zip
        //
        // How does it work?
        //
        // It works in 4 steps:
        //
        // Step 1
        // Takes a PNG sequence and converts it into a PI1 (low-res) or PI3 (high-res monochrome) sequence.
        // The PNG images MUST BE RESIZED TO THE FINAL RESOLUTION
        // That is: 320x200 for low-res and 640x400 for high-res
        // The conversion will take only the green channel to make the conversion and take the nearest greyscale available.
        // PI1 will always be greyscale, number of bitplanes (1/2/3/4) defined by 'target_nb_bitplanes'.
        //   => each bitplane setting will output in a different directory
        // PI3 will always be black & white.
        //
        // Step 2
        // Takes the PI1/PI3 sequence and make an analysis of the differences between frames.
        // It then generates a ".run" file, one per image, containing m68k code and/or blitter data.
        // Parameters of the analysis can be tuned in bw_MakeRun. The most interesting setting is opt_blitter to enable or disable blitter rendering.
        //
        // Step 3
        // Takes an audio file and split it into audio frames (.pcm), one per image.
        // The audio file must be a 16-bits PCM wav with the correct STE final frequency, for instance 50066Hz stereo
        // and please do NOT set any tag in this file (no author composer etc.).
        //
        // Step 4
        // Muxes the .run and .pcm files and generates a ba.dat file (data) and ba.idx file (index)
        //
        // On the UI
        // The first button runs pass 1
        // The second button runs pass 2+3+4 unless in source 'audio_mux_only' is set to "true", in this case it runs pass 3+4 only.
        //
        // Note that the settings in badapple.tos must match the ones in ba.dat, for instance set 'monochrome' to 1 when it's a high-res ba.dat file.
        //
        // Also this generator converts framerate.
        // fps is the framerate the original sequence should be played at (bad apple is 30 fps)
        // target_fps is the framerate it will be played on ST.
        // => lowres: define fps=ntsc_fps/2 so that the fps of the sequence will be a little faster than 30fps but will match the STE clock.
        // => highres: define fps=30 and target_fps=monochrome_fps, so the resulting sequence will have a lot more frames but a lot will contain only audio ("unchanged frames")
        // This is really important to get a good sync between audio and video
        //
        // == ba.dat file format
        // contains all frames sequentially
        // everything is big-endian of course, this is the right order :)
        // w=16 bits
        // -- 1 frame:
        // 1w size of audio frame in bytes, should always be even
        // ?w audio frame
        // 1w size of render code in bytes. if 0x0000: no render, this is an "unchanged frame". Keep the previous render displayed (no buffer swap)
        // ?w code to execute, register a6 must contain the video buffer address, always ends with 0x4e75 (rts)
        // 1w number of blitter operations. -1 if no blitter operation
        // --- blitter operation
        // 1w number of bitplanes (1/2/4)
        // 1w offset from start of screen in bytes (signed, so max 32767)
        // 1w vertical size of operation (number of lines)
        // 1w HOP+OP   (0x0203 copy / 0x0100 and 0x010F blitter fill)
        // ?w graphic data to copy if HOP+OP==0x0203, length of data in bytes = number of bitplanes * lines * 2
        //
        // == ba.idx file format
        // contains the size of each frame. 1w (unsigned) by frame.
        // ends with 0x0000
        //

        BackgroundWorker bw;

        // those are real STE video frequencies (PAL STE) see http://www.atari-forum.com/viewtopic.php?f=16&t=32842&p=335132
        // may be different on STF and NTSC STE. Exact values are important to get a correct audio muxing & replay.
        // audio issues (clicks/duplicate/echoes) on Falcon030 & TT might be related to those values.
        readonly static double pal_fps = 50.05270941;
        readonly static double ntsc_fps = 60.03747642;
        readonly static double monochrome_fps = 71.47532613;

        uint target_nb_bitplanes = 4; // 1 to 4
        // uncomment for color
        double fps = ntsc_fps/2.0; // to fit STE ntsc frequency and avoid 4 'unchanged frames'
        double target_fps = ntsc_fps/2.0; // should be >= fps
        // uncomment for monochrome
        //double fps = 30;
        //double target_fps = monochrome_fps; // should be >= fps
        bool audio_mux_only = false; // set to true if you only changed audio
        int first_pic = 0;
        int last_pic = 6535;
        // set to true if you generate a monochrome highres animation. target bitplanes will be forced to 1
        bool highres = false;

        // Original image sequence location
        // don't forget to change it between lowres and highres
        String original_image = @"D:\badapple\resized\lowres\badapple_{0:00000}.png";

        // audio
        int original_samplesize = 2;   // original should always be 16 bits PCM
        int ste_channels = 2;          // 1=mono, 2=stereo (also applies to the input wav file)
        int soundfrq = 50066;       // audio frequency (+/-1Hz depending on the STE main clock). divide by 2 for 25kHz, 4 for 12kHz, etc.
        String soundfile = @"D:\badapple\badapple_st50_16.wav"; // Original sound file (PCM 16 bit little endian without any tag)

        // Temp files created in step 1
        String degas_source = @"D:\badapple\st{0}b\ba_";

        // Temp files created in step 2
        String runtimefile = @"D:\badapple\st_run\ba_{0:00000}.run";
        String runtimesoundfile = @"D:\badapple\st_run\ba_{0:00000}.pcm";

        // Final files 
        String finalvid = @"S:\Emulateurs\Atari ST\HDD_C\DEV\NEW\ba\ba.dat";
        String finalindex = @"S:\Emulateurs\Atari ST\HDD_C\DEV\NEW\ba\ba.idx";

        // You can stop here unless you cant to tweak settings in bw_MakeRun.

        public MainWindow()
        {
            InitializeComponent();
            if (highres) target_nb_bitplanes = 1;
            degas_source = String.Format(degas_source, (highres?0:target_nb_bitplanes));
        }

        private void converttoPI1_Click(object sender, RoutedEventArgs e)
        {
            btn_pi1.IsEnabled = false;
            btn_runtime.IsEnabled = false;
            bw = new BackgroundWorker();
            bw.WorkerSupportsCancellation = true;
            bw.WorkerReportsProgress = true;
            bw.ProgressChanged += bw_ProgressChanged2;
            bw.RunWorkerCompleted += bw_RunWorkerCompleted;
            bw.DoWork += bw_MakeDegas;
            bw.RunWorkerAsync();

        }

        private void bw_MakeDegas(object sender, DoWorkEventArgs e)
        {
            // palette LUTs for 1, 2, 3, 4 bitplane modes
            int[][] colors = new int[][] { new int[] { 0, 1 },
                new int[] { 0, 2, 3, 1 },
                new int[] { 0, 2, 3, 7, 6, 4, 5, 1 },
                new int[] { 0, 2, 3, 7, 6, 4, 5, 13, 15, 14, 12, 8, 10, 11, 9, 1 } };

            for (int pic = first_pic; pic <= last_pic; pic++) {
                String picfile = String.Format(original_image, pic);
                Console.WriteLine(pic);
                Bitmap myBitmap = new Bitmap(picfile);
                byte[] header = new byte[34];

                int palette = (int)Math.Pow(2, target_nb_bitplanes);
                for (int i = 3; i < 34; i++) header[i] = 0x0f;
                // the palette is actually incorrect but we don't care
                for (int i = 0; i < palette; i++) {
                    int shade = (i * 15) / (palette - 1);
                    byte ste_shade = (byte)(((shade & 0x1) << 3) | ((shade & 0xe) >> 1));
                    header[2 + i * 2] = ste_shade;
                    header[2 + i * 2 + 1] = (byte)(ste_shade * 0x11);
                }

                List<byte> data;

                byte[] pixels = new byte[(highres?2:8)];
                int[] planes = new int[4];

                
                int h = (int)myBitmap.PhysicalDimension.Height;
                int w = (int)myBitmap.PhysicalDimension.Width;
                uint[] pixelData = new uint[w * h];
                //int widthInByte = 4 * w;
                

                using (var fs = new FileStream(degas_source + pic.ToString("D5") + (highres?".pi3":".pi1"), FileMode.Create, FileAccess.Write)) {
                    fs.Write(header, 0, header.Length);

                    data = new List<byte>();

                    int pixcount = 0;
                    planes.Initialize();
                    for (int y = 0; y < myBitmap.PhysicalDimension.Height; y++) {
                        for (int x = 0; x < myBitmap.PhysicalDimension.Width; x++) {
                            int brightness = ((myBitmap.GetPixel(x, y).G >> 4) * palette) / 16;

                            pixelData[x + (y * (int)myBitmap.PhysicalDimension.Width)] = (uint)((0x111111 * 16 * brightness) / palette)  + 0xff000000;

                            brightness = colors[target_nb_bitplanes-1][brightness];
                        
                            int p0 = brightness & 1;                        
                            int p1 = (brightness >> 1) & 1;
                            int p2 = (brightness >> 2) & 1;
                            int p3 = (brightness >> 3) & 1;
                            planes[0] = (planes[0] << 1) | p0;
                            planes[1] = (planes[1] << 1) | p1;
                            planes[2] = (planes[2] << 1) | p2;
                            planes[3] = (planes[3] << 1) | p3;
                            pixcount++;
                            if (pixcount == 16) {
                                pixels.Initialize();
                                pixels[0] = (byte)((planes[0] >> 8) & 0xff);
                                pixels[1] = (byte)(planes[0] & 0xff);
                                if (!highres) {
                                    if (target_nb_bitplanes > 1) {
                                        pixels[2] = (byte)((planes[1] >> 8) & 0xff);
                                        pixels[3] = (byte)(planes[1] & 0xff);
                                    }
                                    if (target_nb_bitplanes > 2) {
                                        pixels[4] = (byte)((planes[2] >> 8) & 0xff);
                                        pixels[5] = (byte)(planes[2] & 0xff);
                                    }
                                    if (target_nb_bitplanes > 3) {
                                        pixels[6] = (byte)((planes[3] >> 8) & 0xff);
                                        pixels[7] = (byte)(planes[3] & 0xff);
                                    }
                                }
                                
                                data.AddRange(pixels.ToList<byte>());
                                pixcount = 0;
                            }
                        }
                    }
                    fs.Write(data.ToArray(), 0, data.Count);
                    header.Initialize();
                    fs.Write(header, 0, 32);
                }
                
                bw.ReportProgress(0, pixelData);
            }
        }



        private void button1_Click(object sender, RoutedEventArgs e)
        {
            btn_pi1.IsEnabled = false;
            btn_runtime.IsEnabled = false;
            bw = new BackgroundWorker();
            bw.WorkerSupportsCancellation = true;
            bw.WorkerReportsProgress = true;
            bw.ProgressChanged += bw_ProgressChanged;
            bw.RunWorkerCompleted += bw_RunWorkerCompleted;
            bw.DoWork += bw_MakeRun;
            bw.RunWorkerAsync();

        }

        private void bw_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            btn_pi1.IsEnabled = true;
            btn_runtime.IsEnabled = true;
        }


        private void bw_ProgressChanged2(object sender, ProgressChangedEventArgs e)
        {
            uint[] pixelData = (uint[])e.UserState;
            WriteableBitmap modifiedImage = new WriteableBitmap((highres?640:320), (highres ? 400 : 200), 72, 72, PixelFormats.Bgra32, BitmapPalettes.WebPalette);
            modifiedImage.WritePixels(new Int32Rect(0, 0, (highres ? 640 : 320), (highres ? 400 : 200)), pixelData, (highres ? 640 : 320) * 4, 0);
            image.Source = modifiedImage;   
        }


        private void bw_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            Object[] par = (Object[])e.UserState;
            String progress = (String)par[0];
            int[] status = (int[])par[1];

            BitmapImage bimg = new BitmapImage();
            bimg.BeginInit();
            bimg.UriSource = new Uri(progress);
            bimg.EndInit();
            image.Source = bimg;

            WriteableBitmap modifiedImage = (highres ? 
                new WriteableBitmap((640 / 16), 400, 72, 72, PixelFormats.Bgra32, BitmapPalettes.WebPalette):
                new WriteableBitmap((320 / 16) * 4, 200, 72, 72, PixelFormats.Bgra32, BitmapPalettes.WebPalette)
                );

            int h = modifiedImage.PixelHeight;
            int w = modifiedImage.PixelWidth;
            uint[] pixelData = new uint[w * h];
            int widthInByte = 4 * w;

            modifiedImage.CopyPixels(pixelData, widthInByte, 0);

            // colors used to display status
            for (int i = 0; i < pixelData.Length; i++) {
                switch (status[i]) {
                    case 1: pixelData[i] = 0xaaff0000; break; // direct value
                    case 2: pixelData[i] = 0xaa00ff00; break; // register value
                    case 3: pixelData[i] = 0xaa0000ff; break; // blitter optimization
                    case 10: pixelData[i] = 0xaa0000ff; break; // blitter waste
                    case 11: pixelData[i] = 0xaaff00ff; break; // blitter instead of direct value
                    case 12: pixelData[i] = 0xaaff00ff; break; // blitter instead of register value
                    case 13: pixelData[i] = 0xaaffff00; break; // blitter waste
                    case 15:
                    case 16:
                    case 17:
                    case 18: pixelData[i] = 0xaa0000ff; break; // blitter fill
                    default: pixelData[i] = 0x0; break; // no change
                }

            }

            modifiedImage.WritePixels(new Int32Rect(0, 0, w, h), pixelData, widthInByte, 0);

            image1.Source = modifiedImage;
        }
    
        private void bw_MakeRun(object sender, DoWorkEventArgs e)
        {

            int trim_start = first_pic;
            int nb_files = last_pic + 1;



            bool opt_addq = true;
            bool opt_move_word = true;
            bool opt_register_long = true;
            bool opt_register_word = true;
            bool opt_blitter = true;
            bool opt_blitter_fill_horizgaps = true;
            bool opt_blitter_fill_vertgaps = true;
            bool write_file = true;
            
            
            byte[] source = new byte[60000];
          //  byte[] old_source = new byte[60000];
            int[] frame = new int[17000];
            int[] status_original = new int[17000];
            int[] status = new int[17000];
            int[] status_blitter = new int[17000];
            int[] status_softwareonly = new int[17000];
            int[] status_tmpblitter = new int[17000];
            int[] status_blittersoftware = new int[17000];
            int[] status_tmpblittersoftware = new int[17000];
            int[] old_frame = new int[17000];
            int[] old_frame2 = new int[17000];
            int[] old_frame3;

            int final_length = 0;
            int softwareonly_length = 0;

            byte[] tmpbuf = new byte[50];

            //int final_framecount=(int)(((nb_files-trim_start)/(double)fps)*target_fps);
            double frame_step = target_fps / (double)fps;

            if (audio_mux_only)
                 goto compil;

            using (System.IO.StreamWriter csv =
                     new System.IO.StreamWriter(@"D:\badapple\log.csv")) {



                for (int final_pic = (int)(trim_start* frame_step) ; final_pic < (int)(nb_files* frame_step); final_pic++) {
                    
                    int pic = (int)(final_pic / frame_step);
                    Console.Write(final_pic + " ("+pic+") ");

                    // System.Threading.Thread.Sleep(1000);

                    //old_source = source;
                    old_frame3 = old_frame; // for rollback
                    old_frame = old_frame2; 
                    old_frame2 = frame;
                    source = new byte[60000];
                    frame = new int[17000];

                    Array.Clear(status_original, 0, status_original.Length);
                    // status values (comparison with previous frame)
                    // 0 = no modification
                    // 1 = modification
                    // 2 = modification using register optimisation
                    // 3 = no modification but taken into account for blitter optimization
                    // 10 = copied with blitter but no modification (wasted time & storage)
                    // 11 = copied with blitter
                    // 12 = copied with blitter
                    // 13 = copied with blitter but no modification (blitter "gap" optimization)
                    // >15 = blitter fill

                    using (var fst = new FileStream(degas_source + pic.ToString("D5") + (highres?".pi3":".pi1"), FileMode.Open, FileAccess.Read)) {
                        fst.Seek(34, SeekOrigin.Begin);
                        fst.Read(source, 0, 32000);
                    }


                    // copy into int tab for easier comparisons between 16-bits words
                    // status=1 if there is a difference with the previous frame
                    bool unchanged = true;
                    for (int i = 0; i < frame.Length; i++) {
                        frame[i] = (int)(source[i * 2] << 8) + (int)source[i * 2 + 1];
                        if (frame[i] != old_frame[i]) status_original[i] = 1;
                        if (frame[i] != old_frame2[i]) unchanged = false;
                    }

                    bool usehardware = false;
                    byte[] blitterOnly = null;
                    byte[] softwareOnly = null;
                    byte[] softwareAfterBlitter = null;

                    if (unchanged) {
                        // very specific optimization: the frame hasn't changed since the very previous one (not the -2 frame since we use double buffering)
                        // in that case we rollback the buffers by -1 and put a $0000 word into the file
                        // to indicate to the player that it needs to hold the previous frame and NOT swap the display/render buffers
                        frame = old_frame2;
                        old_frame2 = old_frame;
                        old_frame = old_frame3;
                        Console.WriteLine("unchanged");

                    } else {
                        //Array.Copy(status, status_original, status.Length);
                        Array.Copy(status_original, status_softwareonly, status.Length);
                        softwareOnly = softwareCheck(ref status_softwareonly, ref source, ref frame, opt_move_word, opt_register_long, opt_register_word, opt_addq);
                        blitterOnly = softwareOnly;
                        softwareAfterBlitter = new byte[0];
                        int bitplanes = 0;
                        if (opt_blitter) {
                            int maxsize = 1000 * 1024;
                            int currentsize = 0;
                            foreach (int bpp in new int[] { 1, 2, 4 }) {
                                Array.Copy(status_original, status_tmpblitter, status_original.Length);
                                Array.Copy(status_original, status_tmpblittersoftware, status_original.Length);

                                byte[] tmp_blitterOnly = blitterCheck(ref status_tmpblitter, ref frame, opt_blitter_fill_horizgaps, opt_blitter_fill_vertgaps, bpp);
                                for (int i = 0; i < status_tmpblitter.Length; i++) {
                                    // remove all work done by blitter
                                    if (status_tmpblitter[i] >= 10) status_tmpblittersoftware[i] = 0;
                                }
                                byte[] tmp_softwareAfterBlitter = softwareCheck(ref status_tmpblittersoftware, ref source, ref frame, opt_move_word, opt_register_long, opt_register_word, opt_addq);
                                for (int i = 0; i < status_tmpblittersoftware.Length; i++) {
                                    // merge blitter+software
                                    if (status_tmpblittersoftware[i] > 0)
                                        status_tmpblitter[i] = status_tmpblittersoftware[i];
                                }

                                currentsize = tmp_blitterOnly.Length + tmp_softwareAfterBlitter.Length;
                                if (currentsize < maxsize) {
                                    bitplanes = bpp;
                                    maxsize = currentsize;
                                    blitterOnly = tmp_blitterOnly;
                                    softwareAfterBlitter = tmp_softwareAfterBlitter;
                                    Array.Copy(status_tmpblitter, status_blitter, status_original.Length);
                                    Array.Copy(status_tmpblittersoftware, status_blittersoftware, status_original.Length);
                                }
                            }
                        }

                        int gain = 0;
                        if (softwareOnly.Length > 0) gain = 100 - (((blitterOnly.Length + softwareAfterBlitter.Length) * 100) / softwareOnly.Length);
                        Console.WriteLine("software={0} blitter={1} blitter+software={2} blit_planes={4} gain={3}%", softwareOnly.Length, blitterOnly.Length, blitterOnly.Length + softwareAfterBlitter.Length, gain, bitplanes);

                        
                        if (opt_blitter && softwareOnly.Length > blitterOnly.Length + softwareAfterBlitter.Length) {
                            Array.Copy(status_blitter, status, status.Length);
                            final_length += blitterOnly.Length + softwareAfterBlitter.Length;
                            usehardware = true;
                        } else {
                            Array.Copy(status_softwareonly, status, status.Length);
                            final_length += softwareOnly.Length;
                        }
                        softwareonly_length += softwareOnly.Length;

                        //if (write_file) fs.Write(cmd_rts, 0, cmd_rts.Length);
                        //Console.WriteLine("cycles={0} cpu={4}% movel={1} movew={5} movel_reg={6} movew_reg={7} lea={2} addq={3}", cpu, stats["movel"], stats["lea"], stats["addq"], cpu / 2600, stats["movew"], stats["movel_reg"], stats["movew_reg"]);
                        // csv.WriteLine("{0};{1};{2}", pic, cpu, fs.Length);
                    }
                    int[] report = new int[status.Length];
                    
                    Array.Copy(status, report, status.Length);
                    bw.ReportProgress(0, new Object[] { String.Format(original_image, pic), report });

                    using (var runfs = new FileStream(String.Format(runtimefile, final_pic), FileMode.Create, FileAccess.Write)) {
                        if (unchanged) {
                            tmpbuf[0] = 0;
                            tmpbuf[1] = 0;
                            runfs.Write(tmpbuf, 0, 2);
                        } else if (usehardware) {
                            tmpbuf[0] = (byte)((softwareAfterBlitter.Length >> 8) & 0xff);
                            tmpbuf[1] = (byte)(softwareAfterBlitter.Length & 0xff);
                            runfs.Write(tmpbuf, 0, 2);
                            runfs.Write(softwareAfterBlitter, 0, softwareAfterBlitter.Length);
                            runfs.Write(blitterOnly, 0, blitterOnly.Length);

                        } else {
                            tmpbuf[0] = (byte)((softwareOnly.Length >> 8) & 0xff);
                            tmpbuf[1] = (byte)(softwareOnly.Length & 0xff);
                            runfs.Write(tmpbuf, 0, 2);
                            runfs.Write(softwareOnly, 0, softwareOnly.Length);
                            tmpbuf[0] = 0xff;
                            tmpbuf[1] = 0xff; // no blitter
                            runfs.Write(tmpbuf, 0, 2);
                        }
                    }
                }
            }

            Console.WriteLine("Final file: {0} (would be {1} without blitter)", final_length, softwareonly_length);
            compil:
            if (write_file) {
               
                byte[] bufsound = new byte[5000];
                byte[] loadsound = new byte[5000 * original_samplesize];
                using (var sound = new FileStream(soundfile, FileMode.Open, FileAccess.Read)) {
                    int seekstart = 0x2e + ((soundfrq * 2 * trim_start) / ((int)fps * 2)) * 2*2;
                    sound.Seek(seekstart, SeekOrigin.Begin);
                    double framesize = (double)soundfrq / target_fps;
                    double shouldbe = 0;
                    int current = 0;
                    for (int pic = (int)(trim_start* frame_step); pic < (int)(nb_files* frame_step); pic++) {
                        using (var fs = new FileStream(String.Format(runtimesoundfile, pic), FileMode.Create, FileAccess.Write)) {
                            int toread = ste_channels * (pic==trim_start? (int)framesize-100: (int)framesize);
                            toread = (toread / 2) * 2; // always even
                            shouldbe += ste_channels * (pic == trim_start ? framesize - 100 : framesize);
                            int diff = ((int)shouldbe / 2) *2 - (current + toread);
                            if (diff > 4) toread += diff;
                            else if (diff < -4) toread -= diff;
                            current += toread;
                            Console.WriteLine("audio frame {0}={1} bytes", pic-trim_start, toread);
                            sound.Read(loadsound, 0, toread * original_samplesize);
                            for (int i = 0; i < toread; i++) {
                                if (original_samplesize == 1) {
                                    bufsound[i] = (byte)(bufsound[i] - 0x80);
                                }else {
                                    bufsound[i] = loadsound[original_samplesize * i+1];
                                }
                            }
                            fs.Write(bufsound, 0, toread);
                        }
                    }
                }

                
                int length = 0;
                using (var final = new FileStream(finalvid, FileMode.Create, FileAccess.Write)) {
                    using (var index = new FileStream(finalindex, FileMode.Create, FileAccess.Write)) {
                        for (int pic = (int)(trim_start*frame_step); pic < (int)(nb_files* frame_step); pic++) {
                            Console.WriteLine("Final file frame {0}", pic-trim_start);
                            int totallength = 0;
                            using (var fs = new FileStream(String.Format(runtimesoundfile, pic), FileMode.Open, FileAccess.Read)) {
                                length = (int)fs.Length;
                                fs.Read(bufsound, 0, length);
                            }

                            source[0] = (byte)((length >> 24) & 0xff);
                            source[1] = (byte)((length >> 16) & 0xff);
                            source[2] = (byte)((length >> 8) & 0xff);
                            source[3] = (byte)(length & 0xff);
                            final.Write(source, 0, 4);
                            final.Write(bufsound, 0, length);
                            totallength = length + 4;

                            using (var fs = new FileStream(String.Format(runtimefile, pic), FileMode.Open, FileAccess.Read)) {
                                length = (int)fs.Length;
                                fs.Read(source, 0, length);
                            }
                            final.Write(source, 0, length);
                            totallength += length;
                            source[0] = (byte)((totallength >> 24) & 0xff);
                            source[1] = (byte)((totallength >> 16) & 0xff);
                            source[2] = (byte)((totallength >> 8) & 0xff);
                            source[3] = (byte)(totallength & 0xff);
                            index.Write(source, 2, 2);
                        }
                        // end of index
                        source[0] = (byte)0;
                        source[1] = (byte)0;
                        source[2] = (byte)0;
                        source[3] = (byte)0;
                        index.Write(source, 2, 2);
                    }
                }
            }

        }

        byte[] cmd_rts = new byte[] { 0x4e, 0x75 };
        byte[] cmd_movel = new byte[] { 0x2c, 0xfc, 0, 0, 0, 0 };
        byte[] cmd_movew = new byte[] { 0x3c, 0xfc, 0, 0 };
        byte[] cmd_lea_w = new byte[] { 0x4d, 0xee, 0, 0 };
        byte[] cmd_addql = new byte[] { 0x50, 0x4e };
        byte[] cmd_moveq = new byte[] { 0x70, 0 }; // register# << 1 in first byte
        byte[] cmd_movew_reg = new byte[] { 0x3C, 0xC0 }; // register# in second byte
        byte[] cmd_movel_reg = new byte[] { 0x2C, 0xC0 }; // register# in second byte
        byte[] cmd_movel_toreg = new byte[] { 0x20, 0x3C, 0, 0, 0, 0 }; // register# << 1 in first byte

        private byte[] softwareCheck(ref int[] status, ref byte[] source, ref int[] frame,
            bool opt_move_word, bool opt_register_long, bool opt_register_word, bool opt_addq)
        {
            List<byte> result = new List<byte>();

            int cpu = 0;
            Dictionary<String, int> stats = new Dictionary<String, int>();
            stats.Add("movel", 0);
            stats.Add("movew", 0);
            stats.Add("movel_reg", 0);
            stats.Add("movew_reg", 0);
            stats.Add("lea", 0);
            stats.Add("addq", 0);
            FileStream fs = null;
           // if (write_file)
            //    fs = new FileStream(String.Format(runtimefile, pic), FileMode.Create, FileAccess.Write);

            // looking for the most repeated data for register optimisation
            Dictionary<int, int> long_stat = new Dictionary<int, int>();
            for (int i = 0; i < frame.Length - 1; i++) {
                if (status[i] == 0 || status[i] >= 10 || status[i + 1] == 0) continue;
                int value = (frame[i] << 16) + frame[i + 1];
                if (!long_stat.ContainsKey(value)) long_stat.Add(value, 1);
                else long_stat[value]++;
            }
            int register = 0;
            Dictionary<int, int> long_reg = new Dictionary<int, int>();
            foreach (KeyValuePair<int, int> kvp in long_stat.OrderByDescending(kvp => kvp.Value)) {
                // Console.WriteLine("{0:X} => {1}", kvp.Key, kvp.Value);
                long_reg.Add(kvp.Key, register);
                register++;
                if (register > 7) break;
                if (kvp.Value < 3) break;
            }
            Dictionary<int, int> word_reg = new Dictionary<int, int>();
            register = 0;
            foreach (int key in long_reg.Keys) {
                int value = key & 0xffff;
                if (!word_reg.ContainsKey(value))
                    word_reg.Add(value, register);
                register++;
            }

            // register init
            register = 0;
            if (opt_register_long || opt_register_word) {
                foreach (int value in long_reg.Keys) {
                    if ((value & 0xffffff80) == 0 || (value & 0xffffff80) == 0xffffff80) {
                        // moveq #xxx,dx
                        cmd_moveq[0] = (byte)(0x70 | (register << 1));
                        cmd_moveq[1] = (byte)(value & 0xff);
                        //if (write_file) fs.Write(cmd_moveq, 0, cmd_moveq.Length);
                        result.AddRange(cmd_moveq);
                        cpu += 4;
                    } else {
                        // move.l #xxx,dx
                        cmd_movel_toreg[0] = (byte)(0x20 | (register << 1));
                        cmd_movel_toreg[2] = (byte)((value >> 24) & 0xff);
                        cmd_movel_toreg[3] = (byte)((value >> 16) & 0xff);
                        cmd_movel_toreg[4] = (byte)((value >> 8) & 0xff);
                        cmd_movel_toreg[5] = (byte)(value & 0xff);
                        //if (write_file) fs.Write(cmd_movel_toreg, 0, cmd_movel_toreg.Length);
                        result.AddRange(cmd_movel_toreg);
                        cpu += 12;
                    }
                    register++;
                }
            }

            int pos = 0;
            int gap = 0;
            while (pos < 16000) {
                if (status[pos] == 0) 
                    { gap += 2; pos++; }
                else {
                    if (gap > 0) {
                        if (opt_addq && gap < 8) {
                            // addq is smaller
                            cmd_addql[0] = (byte)(0x50 | (gap << 1));
                            //if (write_file) fs.Write(cmd_addql, 0, cmd_addql.Length);
                            result.AddRange(cmd_addql);
                            stats["addq"]++;
                        } else {
                            // lea
                            cmd_lea_w[2] = (byte)((gap >> 8) & 0xff);
                            cmd_lea_w[3] = (byte)(gap & 0xff);
                            //if (write_file) fs.Write(cmd_lea_w, 0, cmd_lea_w.Length);
                            result.AddRange(cmd_lea_w);
                            stats["lea"]++;
                        }
                        gap = 0;
                        cpu += 8;
                    }
                    // TODO check if status==2 (register optimization)
                    if (opt_move_word && (status[pos + 1] == 0 && status[pos + 2] == 0 || pos == 16000 - 1)) {
                        // move.w
                        if (opt_register_word && word_reg.ContainsKey(frame[pos])) {
                            // move.w dx,(a6)+
                            //Console.WriteLine("{0:X}", frame[pos]);
                            status[pos] = 2;
                            cmd_movew_reg[1] = (byte)(0xC0 | word_reg[frame[pos]]);
                            //if (write_file) fs.Write(cmd_movew_reg, 0, cmd_movew_reg.Length);
                            result.AddRange(cmd_movew_reg);
                            cpu += 8;
                        } else {
                            // move.w #x,(a6)+
                            for (int i = 0; i < 2; i++) cmd_movew[2 + i] = source[pos * 2 + i];
                            //if (write_file) fs.Write(cmd_movew, 0, cmd_movew.Length);
                            result.AddRange(cmd_movew);
                            cpu += 12;
                        }
                        pos++;
                        stats["movew"]++;
                    } else {
                        // move.l
                        int value = (frame[pos] << 16) + frame[pos + 1];
                        if (opt_register_long && long_reg.ContainsKey(value)) {
                            // move.l dx,(a6)+
                            status[pos] = 2;
                            status[pos + 1] = 2;
                            cmd_movel_reg[1] = (byte)(0xC0 | long_reg[value]);
                            //if (write_file) fs.Write(cmd_movel_reg, 0, cmd_movel_reg.Length);
                            result.AddRange(cmd_movel_reg);
                            stats["movel_reg"]++;
                            cpu += 12;
                        } else {
                            // move.l #x,(a6)+
                            for (int i = 0; i < 4; i++) cmd_movel[2 + i] = source[pos * 2 + i];
                            //if (write_file) fs.Write(cmd_movel, 0, cmd_movel.Length);
                            result.AddRange(cmd_movel);
                            stats["movel"]++;
                            cpu += 20;

                        }
                        pos += 2;
                    }
                } 
            }
            result.AddRange(cmd_rts);
            return result.ToArray();
        }

        private byte[] blitterCheck(ref int[] status, ref int[] frame, bool opt_blitter_fill_horizgaps, bool opt_blitter_fill_vertgaps, int opt_blitter_bitplanes)
        {
            // blitter timings:
            // init $ffff8a00
            // set to 0 or 1: 4 cycles/word (2x faster than generated code not counting lea/move.l)
            // copy source: 8 cycles/word (same than software immediate, software register: 12 cycles)

            // blitter data size:
            // 1word = destination source add from previous operation end
            // 1word = number of lines to copy (n bitplane, 16 pixels-wide = n words)
            // 1word = HOP + OP
            // => 8 bytes (= 1 row of 16 pixels in n bitplanes)
            // followed by data
            // set to 0 or 1: none (OP=0 or 15)
            // source: size of source (OP=3)

            int line_words = (highres ? 40 : 80);

            int blitter_line_min_bitplanes = opt_blitter_bitplanes-1;
            if (blitter_line_min_bitplanes == 0)
                blitter_line_min_bitplanes = 1;
            int blitter_min_lines = 8/opt_blitter_bitplanes;
            if (opt_blitter_bitplanes == 1) opt_blitter_fill_horizgaps = false;

            List<int> result = new List<int>();

            result.Add(opt_blitter_bitplanes);

            int i = 0, previous, current, next;
            
            if (opt_blitter_fill_horizgaps) {
                // fill small gaps horizontally
                while (i < status.Length) {
                    current = status[i];
                    previous = 0;
                    next = 0;
                    if (i > 0) previous = status[i - 1];
                    if (i < status.Length - 1) next = status[i + 1];
                    if ((previous == 1 || previous == 2) && current == 0 && (next == 1 || next == 2))
                        status[i] = 3;
                    
                    i++;
                }
            }
            if (opt_blitter_fill_vertgaps) {
                // fill small gaps vertically
                i = 0;
                while (i < status.Length) {
                    current = status[i];
                    previous = 0;
                    next = 0;
                    if (i > line_words) previous = status[i - line_words];
                    if (i < status.Length - line_words) next = status[i + line_words];
                    if ((previous > 0) && current == 0 && (next > 0))
                        status[i] = 3;
                    else if (opt_blitter_bitplanes == 1) {
                        // fill double gap if 1 bitplane
                        next = 0;
                        if (i < status.Length - line_words*2) next = status[i + line_words*2];
                        if ((previous > 0) && current == 0 && (next > 0))
                            status[i] = 3;
                    }
                    i++;
                }
            }

            int old_offset = 0;
            int offset = 0;
            int blocks_number = -1;


            int splitsize = (highres ? 400 : 200); // size of splitscreen (200 if not used)
            int nb_splits = (highres ? 400 : 200) / splitsize;
            int splitstart = 0;

            int[] blitmodes = new int[] {
                0x0100, // 0x0000 fill
                0x010F,  // 0xFFFF fill
                0x0203 // source
            };

            for (int spl=0; spl<nb_splits; spl++) {
                splitstart = spl * splitsize;

                foreach (int blitmode in blitmodes) {

                    for (int x = 0; x < (line_words / opt_blitter_bitplanes); x++) {
                        offset = x * opt_blitter_bitplanes;
                        List<int> blocks = new List<int>();
                        for (int y = splitstart; y < splitstart + splitsize; y++) {
                            int pos = x * opt_blitter_bitplanes + y * line_words;
                            int stat = 0;
                            for (int b = 0; b < opt_blitter_bitplanes; b++) {
                                switch (blitmode) {
                                    case 0x0203:
                                        // test differences only
                                        if (status[pos + b] > 0 && status[pos + b] < 10) stat++;
                                        break;
                                    case 0x0100:
                                        // must be 0x000
                                        if (frame[pos + b] != 0x0000) {
                                            b = opt_blitter_bitplanes;
                                            stat = 0;
                                        } else if (status[pos + b] > 0 && status[pos + b] < 10) stat++;
                                        break;
                                    case 0x010F:
                                        // must be 0xFFFF
                                        if (frame[pos + b] != 0xFFFF) {
                                            b = opt_blitter_bitplanes;
                                            stat = 0;
                                        } else if (status[pos + b] > 0 && status[pos + b] < 10) stat++;
                                        break;
                                }
                            }
                            if (blocks.Count == 0) {

                                // we're currently not in a block
                                if (stat >= blitter_line_min_bitplanes) {
                                    // blocl start
                                    offset = pos;
                                    blocks.Add(pos);
                                }
                                // else skip line

                            } else if (blocks.Count < blitter_min_lines) {

                                // we're in a potential block
                                if (stat >= blitter_line_min_bitplanes) {
                                    // big enough line, continue
                                    blocks.Add(pos);
                                } else {
                                    // discard block
                                    blocks = new List<int>();
                                }
                            } else {
                                // we're in a big block
                                if (stat >= blitter_line_min_bitplanes) {
                                    // add line
                                    blocks.Add(pos);
                                } else {
                                    // we're done, we close the block and record it
                                    blocks_number++;
                                    int tmp_offset = offset * 2;
                                    result.Add(tmp_offset & 0xFFFF);
                                    result.Add(blocks.Count);
                                    result.Add(blitmode);
                                    //Console.WriteLine("blitter block {0} lines={1}", blocks_number, blocks.Count);

                                    foreach (int b in blocks) {
                                        for (int c = 0; c < opt_blitter_bitplanes; c++) {
                                            if (blitmode == 0x0203) {
                                                result.Add(frame[b + c]);
                                                status[b + c] += 10;
                                            } else status[b + c] += 15;
                                        }
                                    }

                                    // discard
                                    blocks = new List<int>();
                                }
                            }
                        }

                        if (blocks.Count >= blitter_min_lines) {
                            // we're done, we close the last block and record it
                            blocks_number++;
                            int tmp_offset = offset * 2;
                            result.Add(tmp_offset & 0xFFFF);
                            result.Add(blocks.Count);
                            result.Add(blitmode); //  Console.WriteLine("blitter block {0} lines={1}", blocks_number, blocks.Count);

                            foreach (int b in blocks) {
                                for (int c = 0; c < opt_blitter_bitplanes; c++) {
                                    if (blitmode == 0x0203) {
                                        result.Add(frame[b + c]);
                                        status[b + c] += 10;
                                    }
                                    else status[b + c] += 15;
                                }
                            }
                        }
                    }
                }
            }

            //Console.WriteLine("blitter blocks={0}", blocks_number);

            byte[] bresult = new byte[result.Count * 2 + 2];
            bresult[0] = (byte)((blocks_number >> 8) & 0xff);
            bresult[1] = (byte)(blocks_number & 0xff);
            for (i = 0; i < result.Count; i++) {
                bresult[2 + i * 2] = (byte)((result[i] >> 8) & 0xff);
                bresult[2 + i * 2 + 1] = (byte)(result[i] & 0xff);
            }

            return bresult;
        }

    }

}
