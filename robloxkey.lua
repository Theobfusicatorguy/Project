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
			local FlatIdent_76979 = 0;
			while true do
				if (FlatIdent_76979 == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_69270 = 0;
				local b;
				while true do
					if (FlatIdent_69270 == 1) then
						return b;
					end
					if (FlatIdent_69270 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_69270 = 1;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_7126A = 0;
			local Res;
			while true do
				if (FlatIdent_7126A == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_12703 = 0;
			local Plc;
			while true do
				if (FlatIdent_12703 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local FlatIdent_2BD95 = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_2BD95 == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_2BD95 == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_2BD95 = 1;
			end
		end
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
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
		local FlatIdent_60EA1 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_60EA1 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_60EA1 = 2;
			end
			if (FlatIdent_60EA1 == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_60EA1 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_60EA1 = 3;
			end
			if (FlatIdent_60EA1 == 0) then
				Str = nil;
				if not Len then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
				end
				FlatIdent_60EA1 = 1;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_7F35E = 0;
			local Type;
			local Cons;
			while true do
				if (1 == FlatIdent_7F35E) then
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
				if (FlatIdent_7F35E == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_7F35E = 1;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					Inst[3] = gBits16();
					Inst[4] = gBits16();
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					local FlatIdent_455BF = 0;
					while true do
						if (FlatIdent_455BF == 0) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
							break;
						end
					end
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
				if (Enum <= 32) then
					if (Enum <= 15) then
						if (Enum <= 7) then
							if (Enum <= 3) then
								if (Enum <= 1) then
									if (Enum == 0) then
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
										local Edx;
										local Results;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
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
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum == 2) then
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
								else
									Stk[Inst[2]] = {};
								end
							elseif (Enum <= 5) then
								if (Enum > 4) then
									local B;
									local A;
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
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								elseif Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 6) then
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
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
							end
						elseif (Enum <= 11) then
							if (Enum <= 9) then
								if (Enum > 8) then
									if (Inst[2] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum == 10) then
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
							else
								local B;
								local A;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 13) then
							if (Enum > 12) then
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
								local A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum > 14) then
							VIP = Inst[3];
						else
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
					elseif (Enum <= 23) then
						if (Enum <= 19) then
							if (Enum <= 17) then
								if (Enum > 16) then
									local FlatIdent_79536 = 0;
									local A;
									local B;
									while true do
										if (FlatIdent_79536 == 0) then
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_79536 = 1;
										end
										if (FlatIdent_79536 == 1) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
									end
								else
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
								end
							elseif (Enum == 18) then
								local FlatIdent_6A83E = 0;
								local A;
								while true do
									if (FlatIdent_6A83E == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6A83E = 1;
									end
									if (FlatIdent_6A83E == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_6A83E == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_6A83E = 4;
									end
									if (FlatIdent_6A83E == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_6A83E = 2;
									end
									if (FlatIdent_6A83E == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6A83E = 5;
									end
									if (FlatIdent_6A83E == 5) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_6A83E = 6;
									end
									if (FlatIdent_6A83E == 2) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_6A83E = 3;
									end
									if (FlatIdent_6A83E == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_6A83E = 7;
									end
								end
							elseif (Stk[Inst[2]] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 21) then
							if (Enum == 20) then
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
							else
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							end
						elseif (Enum == 22) then
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
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						else
							local A;
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
					elseif (Enum <= 27) then
						if (Enum <= 25) then
							if (Enum > 24) then
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
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							else
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
							end
						elseif (Enum > 26) then
							do
								return Stk[Inst[2]];
							end
						else
							local FlatIdent_35A31 = 0;
							local A;
							while true do
								if (FlatIdent_35A31 == 0) then
									A = Inst[2];
									Stk[A] = Stk[A]();
									break;
								end
							end
						end
					elseif (Enum <= 29) then
						if (Enum == 28) then
							local FlatIdent_189F0 = 0;
							local A;
							while true do
								if (4 == FlatIdent_189F0) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_189F0 = 5;
								end
								if (FlatIdent_189F0 == 1) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_189F0 = 2;
								end
								if (3 == FlatIdent_189F0) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_189F0 = 4;
								end
								if (FlatIdent_189F0 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_189F0 = 3;
								end
								if (FlatIdent_189F0 == 5) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_189F0 = 6;
								end
								if (FlatIdent_189F0 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_189F0 == 0) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_189F0 = 1;
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
					elseif (Enum <= 30) then
						do
							return;
						end
					elseif (Enum == 31) then
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
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
					else
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
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					end
				elseif (Enum <= 49) then
					if (Enum <= 40) then
						if (Enum <= 36) then
							if (Enum <= 34) then
								if (Enum > 33) then
									local A = Inst[2];
									local Results = {Stk[A](Stk[A + 1])};
									local Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								else
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
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum > 35) then
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
							else
								local A = Inst[2];
								Stk[A](Stk[A + 1]);
							end
						elseif (Enum <= 38) then
							if (Enum > 37) then
								local FlatIdent_5477B = 0;
								local A;
								while true do
									if (FlatIdent_5477B == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_5477B = 3;
									end
									if (FlatIdent_5477B == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_5477B = 9;
									end
									if (FlatIdent_5477B == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_5477B == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_5477B = 2;
									end
									if (FlatIdent_5477B == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_5477B = 7;
									end
									if (FlatIdent_5477B == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_5477B = 4;
									end
									if (5 == FlatIdent_5477B) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_5477B = 6;
									end
									if (7 == FlatIdent_5477B) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_5477B = 8;
									end
									if (FlatIdent_5477B == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_5477B = 5;
									end
									if (FlatIdent_5477B == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_5477B = 1;
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
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							end
						elseif (Enum == 39) then
							Stk[Inst[2]] = Env[Inst[3]];
						else
							local A = Inst[2];
							local C = Inst[4];
							local CB = A + 2;
							local Result = {Stk[A](Stk[A + 1], Stk[CB])};
							for Idx = 1, C do
								Stk[CB + Idx] = Result[Idx];
							end
							local R = Result[1];
							if R then
								Stk[CB] = R;
								VIP = Inst[3];
							else
								VIP = VIP + 1;
							end
						end
					elseif (Enum <= 44) then
						if (Enum <= 42) then
							if (Enum == 41) then
								local A;
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
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							else
								local FlatIdent_494F6 = 0;
								local A;
								while true do
									if (FlatIdent_494F6 == 5) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_494F6 = 6;
									end
									if (FlatIdent_494F6 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_494F6 = 4;
									end
									if (FlatIdent_494F6 == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_494F6 = 2;
									end
									if (FlatIdent_494F6 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_494F6 = 7;
									end
									if (FlatIdent_494F6 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_494F6 = 1;
									end
									if (FlatIdent_494F6 == 2) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_494F6 = 3;
									end
									if (FlatIdent_494F6 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										break;
									end
									if (FlatIdent_494F6 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_494F6 = 5;
									end
								end
							end
						elseif (Enum == 43) then
							Stk[Inst[2]] = Inst[3];
						else
							local FlatIdent_578E3 = 0;
							local NewProto;
							local NewUvals;
							local Indexes;
							while true do
								if (FlatIdent_578E3 == 0) then
									NewProto = Proto[Inst[3]];
									NewUvals = nil;
									FlatIdent_578E3 = 1;
								end
								if (FlatIdent_578E3 == 2) then
									for Idx = 1, Inst[4] do
										VIP = VIP + 1;
										local Mvm = Instr[VIP];
										if (Mvm[1] == 51) then
											Indexes[Idx - 1] = {Stk,Mvm[3]};
										else
											Indexes[Idx - 1] = {Upvalues,Mvm[3]};
										end
										Lupvals[#Lupvals + 1] = Indexes;
									end
									Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
									break;
								end
								if (FlatIdent_578E3 == 1) then
									Indexes = {};
									NewUvals = Setmetatable({}, {__index=function(_, Key)
										local FlatIdent_2E34E = 0;
										local Val;
										while true do
											if (FlatIdent_2E34E == 0) then
												Val = Indexes[Key];
												return Val[1][Val[2]];
											end
										end
									end,__newindex=function(_, Key, Value)
										local FlatIdent_2A9F7 = 0;
										local Val;
										while true do
											if (FlatIdent_2A9F7 == 0) then
												Val = Indexes[Key];
												Val[1][Val[2]] = Value;
												break;
											end
										end
									end});
									FlatIdent_578E3 = 2;
								end
							end
						end
					elseif (Enum <= 46) then
						if (Enum > 45) then
							local A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
						else
							local FlatIdent_91B54 = 0;
							local A;
							local Cls;
							while true do
								if (FlatIdent_91B54 == 1) then
									for Idx = 1, #Lupvals do
										local List = Lupvals[Idx];
										for Idz = 0, #List do
											local Upv = List[Idz];
											local NStk = Upv[1];
											local DIP = Upv[2];
											if ((NStk == Stk) and (DIP >= A)) then
												Cls[DIP] = NStk[DIP];
												Upv[1] = Cls;
											end
										end
									end
									break;
								end
								if (FlatIdent_91B54 == 0) then
									A = Inst[2];
									Cls = {};
									FlatIdent_91B54 = 1;
								end
							end
						end
					elseif (Enum <= 47) then
						local FlatIdent_5E109 = 0;
						local A;
						while true do
							if (FlatIdent_5E109 == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5E109 = 1;
							end
							if (1 == FlatIdent_5E109) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_5E109 = 2;
							end
							if (FlatIdent_5E109 == 4) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5E109 = 5;
							end
							if (FlatIdent_5E109 == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5E109 = 4;
							end
							if (FlatIdent_5E109 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (FlatIdent_5E109 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_5E109 = 3;
							end
							if (FlatIdent_5E109 == 5) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_5E109 = 6;
							end
						end
					elseif (Enum == 48) then
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
						local FlatIdent_3F7F4 = 0;
						local A;
						while true do
							if (0 == FlatIdent_3F7F4) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								break;
							end
						end
					end
				elseif (Enum <= 57) then
					if (Enum <= 53) then
						if (Enum <= 51) then
							if (Enum == 50) then
								Stk[Inst[2]]();
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum > 52) then
							local A = Inst[2];
							do
								return Unpack(Stk, A, A + Inst[3]);
							end
						else
							for Idx = Inst[2], Inst[3] do
								Stk[Idx] = nil;
							end
						end
					elseif (Enum <= 55) then
						if (Enum > 54) then
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
							local A = Inst[2];
							local Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
							local Edx = 0;
							for Idx = A, Inst[4] do
								local FlatIdent_43626 = 0;
								while true do
									if (0 == FlatIdent_43626) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
						end
					elseif (Enum == 56) then
						Stk[Inst[2]] = Inst[3] ~= 0;
					else
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					end
				elseif (Enum <= 61) then
					if (Enum <= 59) then
						if (Enum == 58) then
							Stk[Inst[2]] = Upvalues[Inst[3]];
						else
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						end
					elseif (Enum == 60) then
						local FlatIdent_43337 = 0;
						while true do
							if (FlatIdent_43337 == 4) then
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_43337 == 0) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_43337 = 1;
							end
							if (FlatIdent_43337 == 3) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_43337 = 4;
							end
							if (FlatIdent_43337 == 2) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_43337 = 3;
							end
							if (FlatIdent_43337 == 1) then
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_43337 = 2;
							end
						end
					else
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
					end
				elseif (Enum <= 63) then
					if (Enum == 62) then
						local A;
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Stk[A + 1]);
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
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
				elseif (Enum <= 64) then
					if (Stk[Inst[2]] == Inst[4]) then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum == 65) then
					local FlatIdent_4E551 = 0;
					local A;
					while true do
						if (FlatIdent_4E551 == 4) then
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_4E551 = 5;
						end
						if (5 == FlatIdent_4E551) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							FlatIdent_4E551 = 6;
						end
						if (FlatIdent_4E551 == 6) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							break;
						end
						if (FlatIdent_4E551 == 1) then
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							FlatIdent_4E551 = 2;
						end
						if (3 == FlatIdent_4E551) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_4E551 = 4;
						end
						if (FlatIdent_4E551 == 0) then
							A = nil;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_4E551 = 1;
						end
						if (FlatIdent_4E551 == 2) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							FlatIdent_4E551 = 3;
						end
					end
				else
					local FlatIdent_835BC = 0;
					local A;
					while true do
						if (FlatIdent_835BC == 6) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							FlatIdent_835BC = 7;
						end
						if (FlatIdent_835BC == 5) then
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_835BC = 6;
						end
						if (7 == FlatIdent_835BC) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							break;
						end
						if (FlatIdent_835BC == 4) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_835BC = 5;
						end
						if (FlatIdent_835BC == 0) then
							A = nil;
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							FlatIdent_835BC = 1;
						end
						if (FlatIdent_835BC == 3) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							FlatIdent_835BC = 4;
						end
						if (FlatIdent_835BC == 2) then
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							FlatIdent_835BC = 3;
						end
						if (FlatIdent_835BC == 1) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_835BC = 2;
						end
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4C3O00028O00026O002240026O00F03F03103O004261636B67726F756E64436F6C6F723303063O00436F6C6F723303073O0066726F6D524742026O00394003043O005465787403093O00436865636B204B6579027O004003043O0053697A6503053O005544696D322O033O006E6577026O66D63F026O33C33F03083O00506F736974696F6E029A5O99E13F026O66E63F026O00084003063O00506172656E74026O00244003083O005465787453697A65026O003240030A3O0054657874436F6C6F7233025O00C0624003113O004D6F75736542752O746F6E31436C69636B03073O00436F2O6E65637403083O00496E7374616E636503093O00546578744C6162656C026O003E40029A5O99A93F030A3O004B65792053797374656D026O001040026O00E03F030B3O00416E63686F72506F696E7403073O00566563746F723203093O005363722O656E47756903043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030C3O0057616974466F724368696C6403093O00506C61796572477569026O002E4003053O004672616D65026O007940025O00C07240026O00204003083O005549436F726E6572030C3O00436F726E657252616469757303043O005544696D026O001440030A3O005465787442752O746F6E026O002640030F3O00426F7264657253697A65506978656C03063O004163746976652O0103093O004472612O6761626C65026O001C40029A5O99B93F03073O00476574204B6579026O001840030F3O00506C616365686F6C64657254657874030C3O00456E746572204B65793O2E034O00025O00E06F4003163O004261636B67726F756E645472616E73706172656E6379029A5O99C93F031E3O00456E746572204B657920546F20412O63652O732054686520536372697074026O0044C0026O00444003023O00C397030A3O00546578745363616C6564026O002A4003073O0054657874426F78029A5O99E93F029A5O99D93F009D012O00122B3O00014O00340001000E3O0026403O00340001000200040F3O0034000100122B000F00013O002640000F00100001000300040F3O00100001001227001000053O00201800100010000600122O001100073O00122O001200073O00122O001300076O00100013000200102O000B0004001000302O000B0008000900122O000F000A3O002640000F00230001000100040F3O002300010012270010000C3O00200A00100010000D00122O0011000E3O00122O001200013O00122O0013000F3O00122O001400016O00100014000200102O000B000B001000122O0010000C3O00202O00100010000D00122O001100113O00122B001200013O001217001300123O00122O001400016O00100014000200102O000B0010001000122O000F00033O002640000F00280001001300040F3O00280001001039000B0014000200122B3O00153O00040F3O00340001002640000F00050001000A00040F3O0005000100300E000B0016001700121C001000053O00202O00100010000600122O001100193O00122O001200193O00122O001300196O00100013000200102O000B0018001000122O000F00133O00044O000500010026403O00540001001300040F3O0054000100103900040014000200203B000F0004001A002011000F000F001B00062C00113O000100012O00333O00014O000D000F0011000100122O000F001C3O00202O000F000F000D00122O0010001D6O000F000200024O0005000F3O00122O000F000C3O00202O000F000F000D00122O001000033O00122O001100013O00122B001200013O0012370013001E6O000F0013000200102O0005000B000F00122O000F000C3O00202O000F000F000D00122O001000013O00122O001100013O00122O0012001F3O00122O001300016O000F0013000200103900050010000F00300E00050008002000300E00050016001700122B3O00213O0026403O00930001000100040F3O0093000100122B000F00013O002640000F00680001000A00040F3O006800010012270010000C3O00200A00100010000D00122O001100223O00122O001200013O00122O001300223O00122O001400016O00100014000200102O00020010001000122O001000243O00202O00100010000D00122O001100223O00122B001200224O003100100012000200103900020023001000122B000F00133O002640000F00770001000100040F3O007700010012270010001C3O00201000100010000D00122O001100256O0010000200024O000100103O00122O001000263O00202O00100010002700202O00100010002800202O00100010002900122O0012002A6O00100012000200103900010014001000122B000F00033O002640000F00820001001300040F3O00820001001227001000053O002O2000100010000600122O0011002B3O00122O0012002B3O00122O0013002B6O00100013000200102O00020004001000124O00033O00044O00930001002640000F00570001000300040F3O005700010012270010001C3O00200200100010000D00122O0011002C6O0010000200024O000200103O00122O0010000C3O00202O00100010000D00122O001100013O00122O0012002D3O00122O001300013O00122O0014002E4O00310010001400020010390002000B001000122B000F000A3O00040F3O005700010026403O00B00001002F00040F3O00B0000100300E000900160017001219000F00053O00202O000F000F000600122O001000193O00122O001100193O00122O001200196O000F0012000200102O00090018000F00102O00090014000200122O000F001C3O00202O000F000F000D00122B001000304O0042000F000200024O000A000F3O00122O000F00323O00202O000F000F000D00122O001000013O00122O001100336O000F0011000200102O000A0031000F00102O000A0014000900122O000F001C3O00203B000F000F000D00122B001000344O002E000F000200022O0033000B000F3O00122B3O00023O0026403O00C60001001500040F3O00C60001001227000F001C3O00202A000F000F000D00122O001000306O000F000200024O000C000F3O00122O000F00323O00202O000F000F000D00122O001000013O00122O001100336O000F0011000200102O000C0031000F001039000C0014000B00203B000F0009001A002011000F000F001B000215001100014O000C000F001100012O0034000D000D3O000215000D00024O0034000E000E3O00122B3O00353O0026403O00D90001000300040F3O00D9000100300E00020036000100300600020037003800302O00020039003800102O00020014000100122O000F001C3O00202O000F000F000D00122O001000306O000F000200024O0003000F3O00122O000F00323O00202O000F000F000D00122B001000013O00121F001100156O000F0011000200102O00030031000F00102O00030014000200124O000A3O0026404O002O01003A00040F4O002O01001227000F00323O00202O000F000F000D00122O001000013O00122O001100336O000F0011000200102O00080031000F00102O00080014000700122O000F001C3O00202O000F000F000D00122O001000346O000F000200022O00330009000F3O00123F000F000C3O00202O000F000F000D00122O0010000E3O00122O001100013O00122O0012000F3O00122O001300016O000F0013000200102O0009000B000F00122O000F000C3O00202O000F000F000D00122B0010003B3O001224001100013O00122O001200123O00122O001300016O000F0013000200102O00090010000F00122O000F00053O00202O000F000F000600122O001000073O00122O001100073O00122O001200074O0031000F0012000200103900090004000F00300E00090008003C00122B3O002F3O0026403O000C2O01003500040F3O000C2O0100062C000E0003000100012O00333O000D3O00203B000F000B001A002011000F000F001B00062C00110004000100032O00333O00074O00333O000E4O00333O00014O000C000F0011000100040F3O009B2O010026403O00262O01003D00040F3O00262O01001227000F00053O002007000F000F000600122O001000073O00122O001100073O00122O001200076O000F0012000200102O00070004000F00302O0007003E003F00302O00070008004000302O00070016001700122O000F00053O00203B000F000F000600123D001000413O00122O001100413O00122O001200416O000F0012000200102O00070018000F00102O00070014000200122O000F001C3O00202O000F000F000D00122O001000306O000F000200022O00330008000F3O00122B3O003A3O0026403O00482O01002100040F3O00482O01001227000F00053O002025000F000F000600122O001000413O00122O001100413O00122O001200416O000F0012000200102O00050018000F00302O00050042000300102O00050014000200122O000F001C3O00202O000F000F000D0012140010001D6O000F000200024O0006000F3O00122O000F000C3O00202O000F000F000D00122O001000033O00122O001100013O00122O001200013O00122O0013001E6O000F001300020010390006000B000F001227000F000C3O00202F000F000F000D00122O001000013O00122O001100013O00122O001200433O00122O001300016O000F0013000200102O00060010000F00302O00060008004400124O00333O0026403O00782O01000A00040F3O00782O0100122B000F00013O002640000F00572O01000300040F3O00572O010012270010000C3O00202F00100010000D00122O001100033O00122O001200453O00122O001300013O00122O001400016O00100014000200102O00040010001000302O00040042000300122O000F000A3O002640000F00622O01001300040F3O00622O01001227001000053O002O2000100010000600122O001100193O00122O001200193O00122O001300196O00100013000200102O00040018001000124O00133O00044O00782O01000E09000100722O01000F00040F3O00722O010012270010001C3O00200200100010000D00122O001100346O0010000200024O000400103O00122O0010000C3O00202O00100010000D00122O001100013O00122O001200463O00122O001300013O00122O001400464O00310010001400020010390004000B001000122B000F00033O000E09000A004B2O01000F00040F3O004B2O0100300E00040008004700300E00040048003800122B000F00133O00040F3O004B2O010026403O00020001003300040F3O0002000100300E000600160049001230000F00053O00202O000F000F000600122O001000193O00122O001100193O00122O001200196O000F0012000200102O00060018000F00302O00060042000300102O00060014000200122O000F001C3O002002000F000F000D00122O0010004A6O000F000200024O0007000F3O00122O000F000C3O00202O000F000F000D00122O0010004B3O00122O001100013O00122O001200433O00122O001300014O0031000F001300020010390007000B000F001216000F000C3O00202O000F000F000D00122O0010003B3O00122O001100013O00122O0012004C3O00122O001300016O000F0013000200102O00070010000F00124O003D3O00044O000200012O002D8O001E3O00013O00053O00013O0003073O0044657374726F7900044O003A7O0020115O00012O00233O000200012O001E3O00017O00023O00030C3O00736574636C6970626F617264031F3O004B4559204953204F4E4C5920474956454E20544F2057484954454C4953542E00043O0012273O00013O00122B000100024O00233O000200012O001E3O00017O00093O00028O00026O00F03F03063O00676D617463682O033O0025532B03053O007461626C6503063O00696E7365727403043O0067616D6503073O00482O747047657403483O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5468656F62667573696361746F726775792F4B4559532F6D61696E2F5343524950542E747874001C3O00122B3O00014O0034000100023O0026403O00100001000200040F3O0010000100201100030001000300122B000500044O003600030005000500040F3O000D0001001227000700053O00203B0007000700062O0033000800024O0033000900064O000C000700090001000628000300080001000100040F3O000800012O001B000200023O0026403O00020001000100040F3O00020001001227000300073O00200500030003000800122O000500096O0003000500024O000100036O00038O000200033O00124O00023O00044O000200012O001E3O00017O00013O0003053O007061697273010F4O000100018O00010001000200122O000200016O000300016O00020002000400044O000A00010006133O000A0001000600040F3O000A00012O0038000700014O001B000700023O000628000200060001000200040F3O000600012O003800026O001B000200024O001E3O00017O000D3O00028O0003043O0054657874027O0040032O052O009O203O202O2D2047756920746F204C75610A9O203O202O2D2056657273696F6E3A20332E322O0A9O203O202O2D20496E7374616E6365733A2O0A9O203O206C6F63616C205363722O656E477569203D20496E7374616E63652E6E657728225363722O656E47756922290A9O203O206C6F63616C204672616D65203D20496E7374616E63652E6E657728224672616D6522290A9O203O206C6F63616C20546578744C6162656C203D20496E7374616E63652E6E65772822546578744C6162656C22292O0A9O203O202O2D2050726F706572746965733A2O0A9O203O205363722O656E4775692E506172656E74203D2067616D652E506C61796572732E4C6F63616C506C617965723A57616974466F724368696C642822506C6179657247756922290A9O203O205363722O656E4775692E5A496E6465784265686176696F72203D20456E756D2E5A496E6465784265686176696F722E5369626C696E672O0A9O203O204672616D652E506172656E74203D205363722O656E4775690A9O203O204672616D652E4261636B67726F756E64436F6C6F7233203D20436F6C6F72332E66726F6D52474228322O352C20322O352C20322O35290A9O203O204672616D652E426F72646572436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A9O203O204672616D652E426F7264657253697A65506978656C203D20300A9O203O204672616D652E506F736974696F6E203D205544696D322E6E657728302C20302C202D302E2O303233383437303132382C2030290A9O203O204672616D652E53697A65203D205544696D322E6E657728312C20302C20312C2030292O0A9O203O20546578744C6162656C2E506172656E74203D205363722O656E4775690A9O203O20546578744C6162656C2E4261636B67726F756E64436F6C6F7233203D20436F6C6F72332E66726F6D52474228322O352C20322O352C20322O35290A9O203O20546578744C6162656C2E426F72646572436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A9O203O20546578744C6162656C2E426F7264657253697A65506978656C203D20300A9O203O20546578744C6162656C2E506F736974696F6E203D205544696D322E6E657728302E3334374O3230392C20302C20302E33353239342O312O352C2030290A9O203O20546578744C6162656C2E53697A65203D205544696D322E6E657728302C20322O302C20302C203530290A9O203O20546578744C6162656C2E466F6E74203D20456E756D2E466F6E742E536F7572636553616E730A9O203O20546578744C6162656C2E54657874203D2022554E4C4F434B4544205941594159412O59415941220A9O203O20546578744C6162656C2E54657874436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A9O203O20546578744C6162656C2E5465787453697A65203D2031342E3O300A8O20030A3O006C6F6164737472696E67030F3O00506C616365686F6C64657254657874030C3O00436F2O72656374204B657921034O00026O00F03F03043O007761697403073O0044657374726F79030C3O00456E746572204B65793O2E03173O00496E76616C6964206B65792E2054727920616761696E2E003B3O00122B3O00014O0034000100013O0026403O00020001000100040F3O000200012O003A00025O0020080001000200024O000200016O000300016O00020002000200062O0002002700013O00040F3O0027000100122B000200014O0034000300033O000E09000300150001000200040F3O0015000100122B000300043O00121D000400056O000500036O0004000200024O00040001000100044O003A00010026400002001C0001000100040F3O001C00012O003A00045O00300E0004000600072O003A00045O00300E00040002000800122B000200093O0026400002000D0001000900040F3O000D00010012270004000A3O00120B000500096O0004000200014O000400023O00202O00040004000B4O00040002000100122O000200033O00044O000D000100040F3O003A000100122B000200013O002640000200300001000900040F3O003000010012270003000A3O00123E000400096O0003000200014O00035O00302O00030006000C00044O003A0001002640000200280001000100040F3O002800012O003A00035O00303C00030006000D4O00035O00302O00030002000800122O000200093O00044O0028000100040F3O003A000100040F3O000200012O001E3O00017O00", GetFEnv(), ...);
