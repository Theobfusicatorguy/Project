-- Stop stealing, its not the right thing.
local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_1B418 = 0;
			while true do
				if (FlatIdent_1B418 == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local FlatIdent_95CAC = 0;
			local a;
			while true do
				if (FlatIdent_95CAC == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_76979 = 0;
						local b;
						while true do
							if (FlatIdent_76979 == 1) then
								return b;
							end
							if (FlatIdent_76979 == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_76979 = 1;
							end
						end
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_8770C = 0;
			local Res;
			while true do
				if (FlatIdent_8770C == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local FlatIdent_24A02 = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_24A02 == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_24A02 == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_24A02 = 1;
			end
		end
	end
	local function gBits32()
		local FlatIdent_89ECE = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_89ECE == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_89ECE == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_89ECE = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local FlatIdent_C342 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_C342 == 0) then
				Str = nil;
				if not Len then
					local FlatIdent_6C51A = 0;
					while true do
						if (FlatIdent_6C51A == 0) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_C342 = 1;
			end
			if (FlatIdent_C342 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_C342 = 3;
			end
			if (1 == FlatIdent_C342) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_C342 = 2;
			end
			if (FlatIdent_C342 == 3) then
				return Concat(FStr);
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_2D7B8 = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (2 == FlatIdent_2D7B8) then
				for Idx = 1, gBits32() do
					local Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_37E3 = 0;
							while true do
								if (FlatIdent_37E3 == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
			if (FlatIdent_2D7B8 == 1) then
				ConstCount = gBits32();
				Consts = {};
				for Idx = 1, ConstCount do
					local FlatIdent_1743D = 0;
					local Type;
					local Cons;
					while true do
						if (FlatIdent_1743D == 0) then
							Type = gBits8();
							Cons = nil;
							FlatIdent_1743D = 1;
						end
						if (FlatIdent_1743D == 1) then
							if (Type == 1) then
								Cons = gBits8() ~= 0;
							elseif (Type == 2) then
								Cons = gFloat();
							elseif (Type == 3) then
								Cons = gString();
							end
							Consts[Idx] = Cons;
							break;
						end
					end
				end
				Chunk[3] = gBits8();
				FlatIdent_2D7B8 = 2;
			end
			if (FlatIdent_2D7B8 == 0) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_2D7B8 = 1;
			end
		end
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 35) then
					if (Enum <= 17) then
						if (Enum <= 8) then
							if (Enum <= 3) then
								if (Enum <= 1) then
									if (Enum > 0) then
										if (Inst[2] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
									end
								elseif (Enum == 2) then
									local FlatIdent_2458 = 0;
									while true do
										if (FlatIdent_2458 == 4) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_2458 == 1) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2458 = 2;
										end
										if (FlatIdent_2458 == 0) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2458 = 1;
										end
										if (FlatIdent_2458 == 3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2458 = 4;
										end
										if (FlatIdent_2458 == 2) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2458 = 3;
										end
									end
								else
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 5) then
								if (Enum > 4) then
									local FlatIdent_781F8 = 0;
									local A;
									while true do
										if (0 == FlatIdent_781F8) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_781F8 = 1;
										end
										if (FlatIdent_781F8 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											FlatIdent_781F8 = 3;
										end
										if (FlatIdent_781F8 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_781F8 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_781F8 = 4;
										end
										if (FlatIdent_781F8 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_781F8 = 2;
										end
										if (6 == FlatIdent_781F8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_781F8 = 7;
										end
										if (FlatIdent_781F8 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_781F8 = 8;
										end
										if (FlatIdent_781F8 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_781F8 = 6;
										end
										if (FlatIdent_781F8 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_781F8 = 9;
										end
										if (FlatIdent_781F8 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_781F8 = 5;
										end
									end
								else
									local FlatIdent_6A83E = 0;
									local A;
									while true do
										if (FlatIdent_6A83E == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_6A83E = 2;
										end
										if (FlatIdent_6A83E == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6A83E = 1;
										end
										if (FlatIdent_6A83E == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6A83E = 4;
										end
										if (FlatIdent_6A83E == 2) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_6A83E = 3;
										end
										if (FlatIdent_6A83E == 4) then
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
									end
								end
							elseif (Enum <= 6) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							elseif (Enum > 7) then
								local FlatIdent_295EB = 0;
								local A;
								while true do
									if (FlatIdent_295EB == 4) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_295EB = 5;
									end
									if (FlatIdent_295EB == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_295EB = 4;
									end
									if (0 == FlatIdent_295EB) then
										A = nil;
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_295EB = 1;
									end
									if (2 == FlatIdent_295EB) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_295EB = 3;
									end
									if (FlatIdent_295EB == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_295EB = 2;
									end
									if (FlatIdent_295EB == 5) then
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							end
						elseif (Enum <= 12) then
							if (Enum <= 10) then
								if (Enum > 9) then
									Stk[Inst[2]]();
								else
									local FlatIdent_8D1A5 = 0;
									local A;
									while true do
										if (3 == FlatIdent_8D1A5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8D1A5 = 4;
										end
										if (FlatIdent_8D1A5 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_8D1A5 = 2;
										end
										if (FlatIdent_8D1A5 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8D1A5 = 1;
										end
										if (FlatIdent_8D1A5 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_8D1A5 = 3;
										end
										if (5 == FlatIdent_8D1A5) then
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
										if (4 == FlatIdent_8D1A5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8D1A5 = 5;
										end
									end
								end
							elseif (Enum == 11) then
								local FlatIdent_8435E = 0;
								local A;
								while true do
									if (3 == FlatIdent_8435E) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8435E = 4;
									end
									if (5 == FlatIdent_8435E) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_8435E = 6;
									end
									if (FlatIdent_8435E == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8435E = 3;
									end
									if (FlatIdent_8435E == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8435E = 1;
									end
									if (FlatIdent_8435E == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8435E = 2;
									end
									if (FlatIdent_8435E == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_8435E = 8;
									end
									if (FlatIdent_8435E == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8435E = 5;
									end
									if (FlatIdent_8435E == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_8435E = 7;
									end
									if (FlatIdent_8435E == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
								end
							else
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 14) then
							if (Enum == 13) then
								local FlatIdent_DFF4 = 0;
								local A;
								while true do
									if (FlatIdent_DFF4 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_DFF4 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										FlatIdent_DFF4 = 3;
									end
									if (FlatIdent_DFF4 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_DFF4 = 1;
									end
									if (FlatIdent_DFF4 == 1) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_DFF4 = 2;
									end
								end
							else
								local FlatIdent_1FC27 = 0;
								local A;
								while true do
									if (FlatIdent_1FC27 == 0) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1FC27 = 1;
									end
									if (FlatIdent_1FC27 == 4) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1FC27 = 5;
									end
									if (FlatIdent_1FC27 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_1FC27 = 3;
									end
									if (FlatIdent_1FC27 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_1FC27 = 7;
									end
									if (FlatIdent_1FC27 == 1) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_1FC27 = 2;
									end
									if (FlatIdent_1FC27 == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										break;
									end
									if (FlatIdent_1FC27 == 5) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_1FC27 = 6;
									end
									if (FlatIdent_1FC27 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1FC27 = 4;
									end
								end
							end
						elseif (Enum <= 15) then
							local FlatIdent_51FCC = 0;
							local A;
							local Cls;
							while true do
								if (FlatIdent_51FCC == 1) then
									for Idx = 1, #Lupvals do
										local List = Lupvals[Idx];
										for Idz = 0, #List do
											local FlatIdent_81225 = 0;
											local Upv;
											local NStk;
											local DIP;
											while true do
												if (FlatIdent_81225 == 1) then
													DIP = Upv[2];
													if ((NStk == Stk) and (DIP >= A)) then
														local FlatIdent_6679B = 0;
														while true do
															if (FlatIdent_6679B == 0) then
																Cls[DIP] = NStk[DIP];
																Upv[1] = Cls;
																break;
															end
														end
													end
													break;
												end
												if (FlatIdent_81225 == 0) then
													Upv = List[Idz];
													NStk = Upv[1];
													FlatIdent_81225 = 1;
												end
											end
										end
									end
									break;
								end
								if (FlatIdent_51FCC == 0) then
									A = Inst[2];
									Cls = {};
									FlatIdent_51FCC = 1;
								end
							end
						elseif (Enum == 16) then
							local FlatIdent_63AE4 = 0;
							local A;
							while true do
								if (FlatIdent_63AE4 == 0) then
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_63AE4 = 1;
								end
								if (FlatIdent_63AE4 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_63AE4 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_63AE4 = 3;
								end
								if (FlatIdent_63AE4 == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_63AE4 = 2;
								end
								if (FlatIdent_63AE4 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_63AE4 = 4;
								end
							end
						else
							do
								return;
							end
						end
					elseif (Enum <= 26) then
						if (Enum <= 21) then
							if (Enum <= 19) then
								if (Enum > 18) then
									local FlatIdent_5724B = 0;
									local A;
									while true do
										if (FlatIdent_5724B == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (2 == FlatIdent_5724B) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_5724B = 3;
										end
										if (0 == FlatIdent_5724B) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5724B = 1;
										end
										if (FlatIdent_5724B == 3) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_5724B = 4;
										end
										if (4 == FlatIdent_5724B) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5724B = 5;
										end
										if (FlatIdent_5724B == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5724B = 2;
										end
									end
								else
									local FlatIdent_30E68 = 0;
									local A;
									while true do
										if (FlatIdent_30E68 == 4) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_30E68 = 5;
										end
										if (FlatIdent_30E68 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_30E68 = 3;
										end
										if (FlatIdent_30E68 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_30E68 = 7;
										end
										if (FlatIdent_30E68 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_30E68 = 4;
										end
										if (7 == FlatIdent_30E68) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_30E68 == 5) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_30E68 = 6;
										end
										if (FlatIdent_30E68 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_30E68 = 1;
										end
										if (FlatIdent_30E68 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_30E68 = 2;
										end
									end
								end
							elseif (Enum > 20) then
								Stk[Inst[2]] = Inst[3] ~= 0;
							else
								local FlatIdent_45AC8 = 0;
								local A;
								while true do
									if (FlatIdent_45AC8 == 0) then
										A = Inst[2];
										do
											return Unpack(Stk, A, A + Inst[3]);
										end
										break;
									end
								end
							end
						elseif (Enum <= 23) then
							if (Enum > 22) then
								local FlatIdent_44100 = 0;
								local A;
								while true do
									if (FlatIdent_44100 == 0) then
										A = Inst[2];
										do
											return Unpack(Stk, A, Top);
										end
										break;
									end
								end
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum <= 24) then
							local A;
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						elseif (Enum == 25) then
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						end
					elseif (Enum <= 30) then
						if (Enum <= 28) then
							if (Enum == 27) then
								Stk[Inst[2]] = Inst[3];
							else
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum == 29) then
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						end
					elseif (Enum <= 32) then
						if (Enum == 31) then
							local A;
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						else
							local FlatIdent_4D83A = 0;
							local A;
							while true do
								if (FlatIdent_4D83A == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (8 == FlatIdent_4D83A) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_4D83A = 9;
								end
								if (6 == FlatIdent_4D83A) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_4D83A = 7;
								end
								if (FlatIdent_4D83A == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_4D83A = 8;
								end
								if (FlatIdent_4D83A == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4D83A = 2;
								end
								if (FlatIdent_4D83A == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_4D83A = 5;
								end
								if (FlatIdent_4D83A == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4D83A = 3;
								end
								if (FlatIdent_4D83A == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_4D83A = 6;
								end
								if (0 == FlatIdent_4D83A) then
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4D83A = 1;
								end
								if (FlatIdent_4D83A == 3) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_4D83A = 4;
								end
							end
						end
					elseif (Enum <= 33) then
						Stk[Inst[2]] = {};
					elseif (Enum > 34) then
						local A;
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						do
							return Stk[Inst[2]];
						end
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					else
						local FlatIdent_55482 = 0;
						local A;
						while true do
							if (FlatIdent_55482 == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (2 == FlatIdent_55482) then
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_55482 = 3;
							end
							if (FlatIdent_55482 == 0) then
								A = nil;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_55482 = 1;
							end
							if (FlatIdent_55482 == 1) then
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_55482 = 2;
							end
						end
					end
				elseif (Enum <= 53) then
					if (Enum <= 44) then
						if (Enum <= 39) then
							if (Enum <= 37) then
								if (Enum > 36) then
									local A = Inst[2];
									local C = Inst[4];
									local CB = A + 2;
									local Result = {Stk[A](Stk[A + 1], Stk[CB])};
									for Idx = 1, C do
										Stk[CB + Idx] = Result[Idx];
									end
									local R = Result[1];
									if R then
										local FlatIdent_5062 = 0;
										while true do
											if (0 == FlatIdent_5062) then
												Stk[CB] = R;
												VIP = Inst[3];
												break;
											end
										end
									else
										VIP = VIP + 1;
									end
								else
									local FlatIdent_B1F4 = 0;
									local A;
									while true do
										if (FlatIdent_B1F4 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_B1F4 = 4;
										end
										if (FlatIdent_B1F4 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_B1F4 = 7;
										end
										if (2 == FlatIdent_B1F4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_B1F4 = 3;
										end
										if (FlatIdent_B1F4 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_B1F4 = 1;
										end
										if (7 == FlatIdent_B1F4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_B1F4 == 4) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_B1F4 = 5;
										end
										if (FlatIdent_B1F4 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_B1F4 = 2;
										end
										if (FlatIdent_B1F4 == 5) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_B1F4 = 6;
										end
									end
								end
							elseif (Enum == 38) then
								local NewProto = Proto[Inst[3]];
								local NewUvals;
								local Indexes = {};
								NewUvals = Setmetatable({}, {__index=function(_, Key)
									local FlatIdent_439F8 = 0;
									local Val;
									while true do
										if (FlatIdent_439F8 == 0) then
											Val = Indexes[Key];
											return Val[1][Val[2]];
										end
									end
								end,__newindex=function(_, Key, Value)
									local FlatIdent_1E4CB = 0;
									local Val;
									while true do
										if (FlatIdent_1E4CB == 0) then
											Val = Indexes[Key];
											Val[1][Val[2]] = Value;
											break;
										end
									end
								end});
								for Idx = 1, Inst[4] do
									VIP = VIP + 1;
									local Mvm = Instr[VIP];
									if (Mvm[1] == 65) then
										Indexes[Idx - 1] = {Stk,Mvm[3]};
									else
										Indexes[Idx - 1] = {Upvalues,Mvm[3]};
									end
									Lupvals[#Lupvals + 1] = Indexes;
								end
								Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
							else
								local FlatIdent_1D701 = 0;
								local A;
								local B;
								while true do
									if (FlatIdent_1D701 == 0) then
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_1D701 = 1;
									end
									if (1 == FlatIdent_1D701) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
								end
							end
						elseif (Enum <= 41) then
							if (Enum == 40) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_8BD63 = 0;
								local A;
								while true do
									if (0 == FlatIdent_8BD63) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							end
						elseif (Enum <= 42) then
							if not Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 43) then
							local FlatIdent_6066D = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_6066D == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									FlatIdent_6066D = 2;
								end
								if (FlatIdent_6066D == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (4 == FlatIdent_6066D) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_6066D = 5;
								end
								if (FlatIdent_6066D == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6066D = 3;
								end
								if (FlatIdent_6066D == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_6066D = 1;
								end
								if (3 == FlatIdent_6066D) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_6066D = 4;
								end
							end
						else
							local FlatIdent_8F9B8 = 0;
							local A;
							while true do
								if (0 == FlatIdent_8F9B8) then
									A = nil;
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_8F9B8 = 1;
								end
								if (FlatIdent_8F9B8 == 5) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									break;
								end
								if (4 == FlatIdent_8F9B8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8F9B8 = 5;
								end
								if (FlatIdent_8F9B8 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_8F9B8 = 4;
								end
								if (FlatIdent_8F9B8 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_8F9B8 = 3;
								end
								if (1 == FlatIdent_8F9B8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_8F9B8 = 2;
								end
							end
						end
					elseif (Enum <= 48) then
						if (Enum <= 46) then
							if (Enum > 45) then
								local A;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
							else
								local A = Inst[2];
								local Results = {Stk[A](Stk[A + 1])};
								local Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_1B878 = 0;
									while true do
										if (0 == FlatIdent_1B878) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							end
						elseif (Enum == 47) then
							local A;
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local Edx;
							local Results;
							local A;
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results = {Stk[A](Stk[A + 1])};
							Edx = 0;
							for Idx = A, Inst[4] do
								local FlatIdent_62271 = 0;
								while true do
									if (FlatIdent_62271 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 50) then
						if (Enum > 49) then
							local A;
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						else
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 51) then
						local B;
						local A;
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						do
							return Stk[A](Unpack(Stk, A + 1, Inst[3]));
						end
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						do
							return Unpack(Stk, A, Top);
						end
						VIP = VIP + 1;
						Inst = Instr[VIP];
						do
							return;
						end
					elseif (Enum == 52) then
						local FlatIdent_7F9F4 = 0;
						local A;
						while true do
							if (FlatIdent_7F9F4 == 0) then
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								break;
							end
						end
					else
						Stk[Inst[2]] = Upvalues[Inst[3]];
					end
				elseif (Enum <= 62) then
					if (Enum <= 57) then
						if (Enum <= 55) then
							if (Enum > 54) then
								local A = Inst[2];
								Stk[A] = Stk[A]();
							else
								Stk[Inst[2]] = Env[Inst[3]];
							end
						elseif (Enum == 56) then
							do
								return Stk[Inst[2]];
							end
						else
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						end
					elseif (Enum <= 59) then
						if (Enum > 58) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 60) then
						local A;
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
					elseif (Enum > 61) then
						local FlatIdent_8A9D7 = 0;
						local A;
						while true do
							if (3 == FlatIdent_8A9D7) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 4;
							end
							if (FlatIdent_8A9D7 == 4) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 5;
							end
							if (FlatIdent_8A9D7 == 7) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_8A9D7 = 8;
							end
							if (FlatIdent_8A9D7 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 3;
							end
							if (9 == FlatIdent_8A9D7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_8A9D7 == 0) then
								A = nil;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 1;
							end
							if (FlatIdent_8A9D7 == 5) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 6;
							end
							if (FlatIdent_8A9D7 == 6) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 7;
							end
							if (FlatIdent_8A9D7 == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_8A9D7 = 2;
							end
							if (FlatIdent_8A9D7 == 8) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_8A9D7 = 9;
							end
						end
					else
						local FlatIdent_8A8EC = 0;
						local A;
						while true do
							if (FlatIdent_8A8EC == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_8A8EC = 1;
							end
							if (FlatIdent_8A8EC == 9) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								break;
							end
							if (FlatIdent_8A8EC == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_8A8EC = 6;
							end
							if (FlatIdent_8A8EC == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_8A8EC = 4;
							end
							if (FlatIdent_8A8EC == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_8A8EC = 7;
							end
							if (FlatIdent_8A8EC == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_8A8EC = 2;
							end
							if (FlatIdent_8A8EC == 7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_8A8EC = 8;
							end
							if (FlatIdent_8A8EC == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_8A8EC = 3;
							end
							if (FlatIdent_8A8EC == 8) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_8A8EC = 9;
							end
							if (FlatIdent_8A8EC == 4) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_8A8EC = 5;
							end
						end
					end
				elseif (Enum <= 67) then
					if (Enum <= 64) then
						if (Enum > 63) then
							if (Stk[Inst[2]] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local A = Inst[2];
							local Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
							local Edx = 0;
							for Idx = A, Inst[4] do
								local FlatIdent_4058F = 0;
								while true do
									if (FlatIdent_4058F == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
						end
					elseif (Enum <= 65) then
						Stk[Inst[2]] = Stk[Inst[3]];
					elseif (Enum > 66) then
						local FlatIdent_674F6 = 0;
						local A;
						while true do
							if (FlatIdent_674F6 == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_674F6 = 4;
							end
							if (FlatIdent_674F6 == 0) then
								A = nil;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_674F6 = 1;
							end
							if (FlatIdent_674F6 == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_674F6 = 2;
							end
							if (9 == FlatIdent_674F6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_674F6 == 5) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_674F6 = 6;
							end
							if (FlatIdent_674F6 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_674F6 = 3;
							end
							if (FlatIdent_674F6 == 4) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_674F6 = 5;
							end
							if (FlatIdent_674F6 == 7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_674F6 = 8;
							end
							if (FlatIdent_674F6 == 6) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_674F6 = 7;
							end
							if (8 == FlatIdent_674F6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_674F6 = 9;
							end
						end
					elseif (Stk[Inst[2]] == Inst[4]) then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 69) then
					if (Enum == 68) then
						local A;
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
					else
						local B = Inst[3];
						local K = Stk[B];
						for Idx = B + 1, Inst[4] do
							K = K .. Stk[Idx];
						end
						Stk[Inst[2]] = K;
					end
				elseif (Enum <= 70) then
					local A = Inst[2];
					Stk[A] = Stk[A](Stk[A + 1]);
				elseif (Enum == 71) then
					local FlatIdent_17AE1 = 0;
					local A;
					while true do
						if (4 == FlatIdent_17AE1) then
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							FlatIdent_17AE1 = 5;
						end
						if (FlatIdent_17AE1 == 7) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							FlatIdent_17AE1 = 8;
						end
						if (FlatIdent_17AE1 == 5) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							FlatIdent_17AE1 = 6;
						end
						if (FlatIdent_17AE1 == 0) then
							A = nil;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							FlatIdent_17AE1 = 1;
						end
						if (9 == FlatIdent_17AE1) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							break;
						end
						if (FlatIdent_17AE1 == 6) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							FlatIdent_17AE1 = 7;
						end
						if (FlatIdent_17AE1 == 3) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							FlatIdent_17AE1 = 4;
						end
						if (FlatIdent_17AE1 == 2) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							FlatIdent_17AE1 = 3;
						end
						if (FlatIdent_17AE1 == 8) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							FlatIdent_17AE1 = 9;
						end
						if (FlatIdent_17AE1 == 1) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							FlatIdent_17AE1 = 2;
						end
					end
				else
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4C3O00028O00026O002240026O00084003063O00506172656E74026O002440027O004003083O005465787453697A65026O003240030A3O0054657874436F6C6F723303063O00436F6C6F723303073O0066726F6D524742025O00C06240026O00F03F03103O004261636B67726F756E64436F6C6F7233026O00394003043O005465787403093O00436865636B204B657903043O0053697A6503053O005544696D322O033O006E6577026O66D63F026O33C33F03083O00506F736974696F6E029A5O99E13F026O66E63F03113O004D6F75736542752O746F6E31436C69636B03073O00436F2O6E65637403083O00496E7374616E636503093O00546578744C6162656C026O003E40029A5O99A93F030A3O004B65792053797374656D026O00104003093O005363722O656E47756903043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030C3O0057616974466F724368696C6403093O00506C61796572477569026O002E40026O00E03F030B3O00416E63686F72506F696E7403073O00566563746F723203053O004672616D65026O007940025O00C07240026O00204003083O005549436F726E6572030C3O00436F726E657252616469757303043O005544696D026O001440030A3O005465787442752O746F6E026O002640030F3O00426F7264657253697A65506978656C03063O004163746976652O0103093O004472612O6761626C65026O001C40029A5O99B93F03073O00476574204B6579026O001840030F3O00506C616365686F6C64657254657874030C3O00456E746572204B65793O2E034O00025O00E06F4003163O004261636B67726F756E645472616E73706172656E6379029A5O99C93F031E3O00456E746572204B657920546F20412O63652O732054686520536372697074026O004440026O0044C003023O00C397030A3O00546578745363616C6564026O002A4003073O0054657874426F78029A5O99E93F029A5O99D93F008F012O00121B3O00014O001C0001000E3O0026423O00340001000200043A3O0034000100121B000F00013O002642000F000A0001000300043A3O000A0001001048000B0004000200121B3O00053O00043A3O00340001002642000F00150001000600043A3O0015000100301D000B000700080012390010000A3O00202O00100010000B00122O0011000C3O00122O0012000C3O00122O0013000C6O00100013000200102O000B0009001000122O000F00033O002642000F00200001000D00043A3O002000010012360010000A3O00203B00100010000B00122O0011000F3O00122O0012000F3O00122O0013000F6O00100013000200102O000B000E001000302O000B0010001100122O000F00063O002642000F00050001000100043A3O00050001001236001000133O00202400100010001400122O001100153O00122O001200013O00122O001300163O00122O001400016O00100014000200102O000B0012001000122O001000133O00202O00100010001400122O001100183O00121B001200013O001204001300193O00122O001400016O00100014000200102O000B0017001000122O000F000D3O00044O000500010026423O00540001000300043A3O00540001001048000400040002002007000F0004001A002027000F000F001B00062600113O000100012O00413O00014O0032000F0011000100122O000F001C3O00202O000F000F001400122O0010001D6O000F000200024O0005000F3O00122O000F00133O00202O000F000F001400122O0010000D3O00122O001100013O00121B001200013O00122F0013001E6O000F0013000200102O00050012000F00122O000F00133O00202O000F000F001400122O001000013O00122O001100013O00122O0012001F3O00122O001300016O000F0013000200104800050017000F00301D00050010002000301D00050007000800121B3O00213O0026423O00930001000100043A3O0093000100121B000F00013O002642000F00660001000100043A3O006600010012360010001C3O00200600100010001400122O001100226O0010000200024O000100103O00122O001000233O00202O00100010002400202O00100010002500202O00100010002600122O001200276O00100012000200104800010004001000121B000F000D3O002642000F00710001000300043A3O007100010012360010000A3O00201300100010000B00122O001100283O00122O001200283O00122O001300286O00100013000200102O0002000E001000124O000D3O00044O00930001000E01000600820001000F00043A3O00820001001236001000133O00202400100010001400122O001100293O00122O001200013O00122O001300293O00122O001400016O00100014000200102O00020017001000122O0010002B3O00202O00100010001400122O001100293O00121B001200294O00290010001200020010480002002A001000121B000F00033O002642000F00570001000D00043A3O005700010012360010001C3O00200300100010001400122O0011002C6O0010000200024O000200103O00122O001000133O00202O00100010001400122O001100013O00122O0012002D3O00122O001300013O00122O0014002E4O002900100014000200104800020012001000121B000F00063O00043A3O005700010026423O00B00001002F00043A3O00B0000100301D00090007000800120E000F000A3O00202O000F000F000B00122O0010000C3O00122O0011000C3O00122O0012000C6O000F0012000200102O00090009000F00102O00090004000200122O000F001C3O00202O000F000F001400121B001000304O0008000F000200024O000A000F3O00122O000F00323O00202O000F000F001400122O001000013O00122O001100336O000F0011000200102O000A0031000F00102O000A0004000900122O000F001C3O002007000F000F001400121B001000344O0046000F000200022O0041000B000F3O00121B3O00023O0026423O00C60001000500043A3O00C60001001236000F001C3O002016000F000F001400122O001000306O000F000200024O000C000F3O00122O000F00323O00202O000F000F001400122O001000013O00122O001100336O000F0011000200102O000C0031000F001048000C0004000B002007000F0009001A002027000F000F001B00021E001100014O0019000F001100012O001C000D000D3O00021E000D00024O001C000E000E3O00121B3O00353O0026423O00D90001000D00043A3O00D9000100301D00020036000100301F00020037003800302O00020039003800102O00020004000100122O000F001C3O00202O000F000F001400122O001000306O000F000200024O0003000F3O00122O000F00323O00202O000F000F001400121B001000013O001210001100056O000F0011000200102O00030031000F00102O00030004000200124O00063O0026424O002O01003A00043A4O002O01001236000F00323O002009000F000F001400122O001000013O00122O001100336O000F0011000200102O00080031000F00102O00080004000700122O000F001C3O00202O000F000F001400122O001000346O000F000200022O00410009000F3O00121A000F00133O00202O000F000F001400122O001000153O00122O001100013O00122O001200163O00122O001300016O000F0013000200102O00090012000F00122O000F00133O00202O000F000F001400121B0010003B3O001220001100013O00122O001200193O00122O001300016O000F0013000200102O00090017000F00122O000F000A3O00202O000F000F000B00122O0010000F3O00122O0011000F3O00122O0012000F4O0029000F001200020010480009000E000F00301D00090010003C00121B3O002F3O0026423O000C2O01003500043A3O000C2O01000626000E0003000100012O00413O000D3O002007000F000B001A002027000F000F001B00062600110004000100032O00413O00074O00413O000E4O00413O00014O0019000F0011000100043A3O008D2O010026423O00262O01003D00043A3O00262O01001236000F000A3O00203D000F000F000B00122O0010000F3O00122O0011000F3O00122O0012000F6O000F0012000200102O0007000E000F00302O0007003E003F00302O00070010004000302O00070007000800122O000F000A3O002007000F000F000B00122E001000413O00122O001100413O00122O001200416O000F0012000200102O00070009000F00102O00070004000200122O000F001C3O00202O000F000F001400122O001000306O000F000200022O00410008000F3O00121B3O003A3O0026423O00482O01002100043A3O00482O01001236000F000A3O002047000F000F000B00122O001000413O00122O001100413O00122O001200416O000F0012000200102O00050009000F00302O00050042000D00102O00050004000200122O000F001C3O00202O000F000F00140012180010001D6O000F000200024O0006000F3O00122O000F00133O00202O000F000F001400122O0010000D3O00122O001100013O00122O001200013O00122O0013001E6O000F0013000200103E00060012000F00122O000F00133O00202O000F000F001400122O001000013O00122O001100013O00122O001200433O00122O001300016O000F0013000200102O00060017000F00302O00060010004400121B3O00333O0026423O006A2O01000600043A3O006A2O01001236000F001C3O002003000F000F001400122O001000346O000F000200024O0004000F3O00122O000F00133O00202O000F000F001400122O001000013O00122O001100453O00122O001200013O00122O001300454O0029000F0013000200103E00040012000F00122O000F00133O00202O000F000F001400122O0010000D3O00122O001100463O00122O001200013O00122O001300016O000F0013000200102O00040017000F00302O00040042000D00301D00040010004700303C00040048003800122O000F000A3O00202O000F000F000B00122O0010000C3O00122O0011000C3O00122O0012000C6O000F0012000200102O00040009000F00124O00033O0026423O00020001003300043A3O0002000100301D000600070049001244000F000A3O00202O000F000F000B00122O0010000C3O00122O0011000C3O00122O0012000C6O000F0012000200102O00060009000F00302O00060042000D00102O00060004000200122O000F001C3O002003000F000F001400122O0010004A6O000F000200024O0007000F3O00122O000F00133O00202O000F000F001400122O0010004B3O00122O001100013O00122O001200433O00122O001300014O0029000F0013000200104800070012000F001243000F00133O00202O000F000F001400122O0010003B3O00122O001100013O00122O0012004C3O00122O001300016O000F0013000200102O00070017000F00124O003D3O00044O000200012O000F8O00113O00013O00053O00013O0003073O0044657374726F7900044O00357O0020275O00012O00343O000200012O00113O00017O00023O00030C3O00736574636C6970626F617264031F3O004B4559204953204F4E4C5920474956454E20544F2057484954454C4953542E00043O0012363O00013O00121B000100024O00343O000200012O00113O00017O000C3O00028O00026O00F03F03043O007761726E03153O004661696C656420746F206665746368206B6579733A027O004003483O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5468656F62667573696361746F726775792F4B4559532F6D61696E2F5343524950542E74787403043O007469636B03053O007063612O6C03063O00676D617463682O033O0025532B03053O007461626C6503063O00696E7365727400303O00121B3O00014O001C000100043O000E010002001300013O00043A3O0013000100062A000200100001000100043A3O0010000100121B000500013O002642000500070001000100043A3O00070001001236000600033O001223000700046O000800036O0006000800014O00068O000600023O00044O000700012O002100056O0041000400053O00121B3O00053O000E010001002000013O00043A3O0020000100121B000500063O001236000600074O00370006000100022O0045000100050006001236000500083O00062600063O000100012O00413O00014O002D0005000200062O0041000300064O0041000200053O00121B3O00023O0026423O00020001000500043A3O0002000100202700050003000900121B0007000A4O003F00050007000700043A3O002B00010012360009000B3O00200700090009000C2O0041000A00044O0041000B00084O00190009000B0001000625000500260001000100043A3O002600012O0038000400023O00043A3O000200012O00113O00013O00013O00023O0003043O0067616D6503073O00482O747047657400063O0012333O00013O00206O00024O00029O0000029O008O00017O00033O00028O00026O00F03F03053O00706169727301203O00121B000100014O001C000200023O000E01000200060001000100043A3O000600012O001500036O0038000300023O000E01000100020001000100043A3O0002000100121B000300013O000E010002000D0001000300043A3O000D000100121B000100023O00043A3O00020001002642000300090001000100043A3O000900012O003500046O00300004000100024O000200043O00122O000400036O000500026O00040002000600044O001A00010006403O001A0001000800043A3O001A00012O0015000900014O0038000900023O000625000400160001000200043A3O0016000100121B000300023O00043A3O0009000100043A3O000200012O00113O00017O000D3O00028O0003043O0054657874026O00F03F03043O007761697403073O0044657374726F79027O00400361052O009O20202O2D2047756920746F204C75610A2O2D2056657273696F6E3A20332E322O0A2O2D20496E7374616E6365733A2O0A6C6F63616C205363722O656E477569203D20496E7374616E63652E6E657728225363722O656E47756922290A6C6F63616C204672616D65203D20496E7374616E63652E6E657728224672616D6522290A6C6F63616C205465787442752O746F6E203D20496E7374616E63652E6E657728225465787442752O746F6E22292O0A2O2D50726F706572746965733A2O0A5363722O656E4775692E506172656E74203D2067616D652E506C61796572732E4C6F63616C506C617965723A57616974466F724368696C642822506C6179657247756922290A5363722O656E4775692E5A496E6465784265686176696F72203D20456E756D2E5A496E6465784265686176696F722E5369626C696E672O0A4672616D652E506172656E74203D205363722O656E4775690A4672616D652E4261636B67726F756E64436F6C6F7233203D20436F6C6F72332E66726F6D52474228322O352C20322O352C20322O35290A4672616D652E426F72646572436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A4672616D652E426F7264657253697A65506978656C203D20300A4672616D652E53697A65203D205544696D322E6E657728312C20302C20302E3233383437332O37332C2030292O0A5465787442752O746F6E2E506172656E74203D204672616D650A5465787442752O746F6E2E4261636B67726F756E64436F6C6F7233203D20436F6C6F72332E66726F6D52474228322O352C20322O352C20322O35290A5465787442752O746F6E2E426F72646572436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A5465787442752O746F6E2E426F7264657253697A65506978656C203D20300A5465787442752O746F6E2E506F736974696F6E203D205544696D322E6E657728302E32352C20302C20302E32345O392O352C2030290A5465787442752O746F6E2E53697A65203D205544696D322E6E657728302E352C20302C20302E352C2030290A5465787442752O746F6E2E466F6E74203D20456E756D2E466F6E742E536F7572636553616E730A5465787442752O746F6E2E54657874203D2022736372697074207374692O6C206F6E20646576656C6F706D656E742C20636C69636B206D6520746F20636C6F7365220A5465787442752O746F6E2E54657874436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A5465787442752O746F6E2E5465787453697A65203D2031342E3O302O0A2O2D20536372697074733A2O0A6C6F63616C2066756E6374696F6E20595A465246415F66616B655F7363726970742829202O2D205465787442752O746F6E2E4C6F63616C536372697074200A096C6F63616C20736372697074203D20496E7374616E63652E6E657728274C6F63616C536372697074272C205465787442752O746F6E292O0A096C6F63616C2042752O746F6E203D207363726970742E506172656E740A090A096C6F63616C2066756E6374696F6E2064657374726F794772616E64706172656E7428290A2O0969662042752O746F6E2E506172656E7420616E642042752O746F6E2E506172656E742E506172656E74207468656E0A3O0942752O746F6E2E506172656E742E506172656E743A44657374726F7928290A2O09656E640A09656E640A090A0942752O746F6E2E4D6F75736542752O746F6E31436C69636B3A436F2O6E6563742864657374726F794772616E64706172656E74290A090A656E640A636F726F7574696E652E7772617028595A465246415F66616B655F7363726970742928292O0A8O20030A3O006C6F6164737472696E67030F3O00506C616365686F6C64657254657874030C3O00436F2O72656374204B657921034O00030C3O00456E746572204B65793O2E03173O00496E76616C6964206B65792E2054727920616761696E2E00413O00121B3O00014O001C000100013O0026423O00020001000100043A3O000200012O003500025O00200D0001000200024O000200016O000300016O00020002000200062O0002002700013O00043A3O0027000100121B000200014O001C000300033O002642000200160001000300043A3O00160001001236000400043O00122C000500036O0004000200014O000400023O00202O0004000400054O00040002000100122O000200063O0026420002001E0001000600043A3O001E000100121B000300073O00120C000400086O000500036O0004000200024O00040001000100044O004000010026420002000D0001000100043A3O000D00012O003500045O00300200040009000A4O00045O00302O00040002000B00122O000200033O00044O000D000100043A3O0040000100121B000200014O001C000300033O002642000200290001000100043A3O0029000100121B000300013O002642000300340001000300043A3O00340001001236000400043O001222000500036O0004000200014O00045O00302O00040009000C00044O004000010026420003002C0001000100043A3O002C00012O003500045O00300200040009000D4O00045O00302O00040002000B00122O000300033O00044O002C000100043A3O0040000100043A3O0029000100043A3O0040000100043A3O000200012O00113O00017O00", GetFEnv(), ...);
