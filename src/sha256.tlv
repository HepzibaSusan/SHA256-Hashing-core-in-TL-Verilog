\m5_TLV_version 1d: tl-x.org
\m5

   use(m5-1.0)   

\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
   parameter MAX_BYTES  = 1024;    
   parameter MAX_BLOCKS = (MAX_BYTES + 9 + 63) / 64; 
   logic [31:0] num_blocks;    
   logic [31:0] block_idx;
   logic [7:0]  msg_bytes [0:MAX_BYTES-1];
   logic [511:0] blocks [0:MAX_BLOCKS-1];
   integer      msg_len;                       
   string       msg;                           
   integer k, i, bi, blk;
  
   logic [31:0] K [0:63];
   logic [31:0] W [0:63];         
   logic [31:0] H_init [0:7];
   
   logic [255:0] sha_hashcode;
   logic sha_done;


   initial
      begin
         
         H_init[0] = 32'h6A09E667;
         H_init[1] = 32'hBB67AE85;
         H_init[2] = 32'h3C6EF372;
         H_init[3] = 32'hA54FF53A;
         H_init[4] = 32'h510E527F;
         H_init[5] = 32'h9B05688C;
         H_init[6] = 32'h1F83D9AB;
         H_init[7] = 32'h5BE0CD19;

         //ROUND CONSTANTS
         K[ 0] = 32'h428A2F98;
         K[ 1] = 32'h71374491;
         K[ 2] = 32'hB5C0FBCF;
         K[ 3] = 32'hE9B5DBA5;
         K[ 4] = 32'h3956C25B;
         K[ 5] = 32'h59F111F1;
         K[ 6] = 32'h923F82A4;
         K[ 7] = 32'hAB1C5ED5;
         K[ 8] = 32'hD807AA98;
         K[ 9] = 32'h12835B01;
         K[10] = 32'h243185BE;
         K[11] = 32'h550C7DC3;
         K[12] = 32'h72BE5D74;
         K[13] = 32'h80DEB1FE;
         K[14] = 32'h9BDC06A7;
         K[15] = 32'hC19BF174;
         K[16] = 32'hE49B69C1;
         K[17] = 32'hEFBE4786;
         K[18] = 32'h0FC19DC6;
         K[19] = 32'h240CA1CC;
         K[20] = 32'h2DE92C6F;
         K[21] = 32'h4A7484AA;
         K[22] = 32'h5CB0A9DC;
         K[23] = 32'h76F988DA;
         K[24] = 32'h983E5152;
         K[25] = 32'hA831C66D;
         K[26] = 32'hB00327C8;
         K[27] = 32'hBF597FC7;
         K[28] = 32'hC6E00BF3;
         K[29] = 32'hD5A79147;
         K[30] = 32'h06CA6351;
         K[31] = 32'h14292967;
         K[32] = 32'h27B70A85;
         K[33] = 32'h2E1B2138;
         K[34] = 32'h4D2C6DFC;
         K[35] = 32'h53380D13;
         K[36] = 32'h650A7354;
         K[37] = 32'h766A0ABB;
         K[38] = 32'h81C2C92E;
         K[39] = 32'h92722C85;
         K[40] = 32'hA2BFE8A1;
         K[41] = 32'hA81A664B;
         K[42] = 32'hC24B8B70;
         K[43] = 32'hC76C51A3;
         K[44] = 32'hD192E819;
         K[45] = 32'hD6990624;
         K[46] = 32'hF40E3585;
         K[47] = 32'h106AA070;
         K[48] = 32'h19A4C116;
         K[49] = 32'h1E376C08;
         K[50] = 32'h2748774C;
         K[51] = 32'h34B0BCB5;
         K[52] = 32'h391C0CB3;
         K[53] = 32'h4ED8AA4A;
         K[54] = 32'h5B9CCA4F;
         K[55] = 32'h682E6FF3;
         K[56] = 32'h748F82EE;
         K[57] = 32'h78A5636F;
         K[58] = 32'h84C87814;
         K[59] = 32'h8CC70208;
         K[60] = 32'h90BEFFFA;
         K[61] = 32'hA4506CEB;
         K[62] = 32'hBEF9A3F7;
         K[63] = 32'hC67178F2;

         // ---- Message to hash: EDIT HERE ----
         msg = "";
         msg_len = msg.len();
         for (k = 0; k < msg_len; k = k + 1)
            msg_bytes[k] = msg[k];
      end

   function automatic [31:0] small_sigma0(input [31:0] x);
      begin
          small_sigma0 =
              ((x >> 7)  | (x << 25)) ^
              ((x >> 18) | (x << 14)) ^
              (x >> 3);
      end
   endfunction

   function automatic [31:0] small_sigma1(input [31:0] x);
      begin
          small_sigma1 =
              ((x >> 17) | (x << 15)) ^
              ((x >> 19) | (x << 13)) ^
              (x >> 10);
      end
   endfunction

   
always_comb
   begin
      num_blocks = (msg_len + 9 + 63) / 64;  

      for (blk = 0; blk < MAX_BLOCKS; blk = blk + 1)      
         begin
            for (bi = 0; bi < 64; bi = bi + 1)
               begin
                  if ((blk*64 + bi) < msg_len)
                     blocks[blk][511 - bi*8 -: 8] = msg_bytes[blk*64 + bi];
                  else if ((blk*64 + bi) == msg_len)
                     blocks[blk][511 - bi*8 -: 8] = 8'h80;
                  else
                     blocks[blk][511 - bi*8 -: 8] = 8'h00;
               end
         end
      blocks[num_blocks-1][63:0] = msg_len * 8;  
   end

   always_comb
      begin
         for(i=0;i<=15;i++)
            begin
               W[i] = blocks[block_idx][(512-(32*i))-1 -: 32];
            end
         for(i=16;i<=63;i++)
            begin
               W[i] = W[i-7] + W[i-16] + small_sigma0(W[i-15]) + small_sigma1(W[i-2]);
            end
      end



\TLV Rotn($_rotnout, $_x, $_n)
   $_rotnout[31:0] = ($_x >> $_n) | ($_x << m5_calc(32 - $_n));
\TLV Ch($_chout, $_e, $_f, $_g)
   $_chout[31:0] = ($_e & $_f) ^ ((~($_e)) & $_g);
\TLV Maj($_majout, $_a, $_b, $_c)
   $_majout[31:0] = ($_a & $_b) ^ ($_a & $_c) ^ ($_b & $_c);
\TLV
   |sha256
      @0
         $reset = *reset;

         m5+Rotn($rot2[31:0], /word[0]>>1$reg, 2)
         m5+Rotn($rot13[31:0], /word[0]>>1$reg, 13)
         m5+Rotn($rot22[31:0], /word[0]>>1$reg, 22)
         $big_sigma_zero[31:0] = $rot2 ^ $rot13 ^ $rot22;

         m5+Rotn($rot6[31:0], /word[4]>>1$reg, 6)
         m5+Rotn($rot11[31:0], /word[4]>>1$reg, 11)
         m5+Rotn($rot25[31:0], /word[4]>>1$reg, 25)
         $big_sigma_one[31:0] = $rot6 ^ $rot11 ^ $rot25;

         m5+Ch($ch[31:0], /word[4]>>1$reg, /word[5]>>1$reg, /word[6]>>1$reg)
         m5+Maj($maj[31:0], /word[0]>>1$reg, /word[1]>>1$reg, /word[2]>>1$reg)

         $T1[31:0] = /word[7]>>1$reg + $big_sigma_one + $ch + K[>>1$round] + W[>>1$round];
         $T2[31:0] = $big_sigma_zero + $maj;

         $is_last_round = (>>1$round == 6'd63);
         $is_last_block = (>>1$block_idx == (*num_blocks - 32'd1));
         $advance = $is_last_round & !$is_last_block & !(>>1$finished);
         $done = $is_last_round & $is_last_block & !(>>1$finished);
         $finished = $reset ? 1'b0 : (>>1$finished | $done);

         /word[7:0]
            $reset = |sha256$reset;
            $done = |sha256$done;
            $post[31:0] =
               |sha256>>1$finished
                   ? >>1$reg :
               #word == 0
                   ? |sha256$T1 + |sha256$T2 :
               #word == 4
                   ? |sha256/word[(#word + 7) % 8]>>1$reg + |sha256$T1 :
               //default
                     |sha256/word[(#word + 7) % 8]>>1$reg;
            $new[31:0] = >>1$seed + $post;
            $reg[31:0] = $reset ? *H_init\[#word\] : |sha256$advance ? $new : $post;
            $seed[31:0] = $reset ? *H_init\[#word\] : |sha256$advance ? $new : >>1$seed;
            ?$done
               $hash[31:0] = $new;
            
         
         $round[5:0] = $reset ? 6'd0 :
                       $advance ? 6'd0 :
                       (>>1$round < 6'd63) ? (>>1$round + 6'd1) :
                       >>1$round;

         $block_idx[3:0] = $reset ? 4'd0 :
                           $advance ? (>>1$block_idx + 4'd1) :
                           >>1$block_idx;

         *block_idx = >>1$block_idx;
         
         

         ?$done
            $hash_final[255:0] =  {/word[0]$hash, /word[1]$hash, /word[2]$hash, /word[3]$hash, /word[4]$hash, /word[5]$hash, /word[6]$hash, /word[7]$hash};
         *sha_hashcode = $hash_final;
         *sha_done = $finished;
         *passed = *sha_done;
         *failed = 1'b0;
         
        
\SV
      always @(posedge sha_done)
      begin
              $display("SHA-256 digest = %064h", sha_hashcode);
      end
endmodule
