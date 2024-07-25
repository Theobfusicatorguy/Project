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
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_12703 = 0;
			local Res;
			while true do
				if (FlatIdent_12703 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_2BD95 = 0;
			local Plc;
			while true do
				if (FlatIdent_2BD95 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local FlatIdent_23BE8 = 0;
		local a;
		while true do
			if (1 == FlatIdent_23BE8) then
				return a;
			end
			if (FlatIdent_23BE8 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_23BE8 = 1;
			end
		end
	end
	local function gBits16()
		local FlatIdent_31A5A = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_31A5A == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_31A5A == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_31A5A = 1;
			end
		end
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_31905 = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_31905 == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_31905 = 2;
			end
			if (0 == FlatIdent_31905) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_31905 = 1;
			end
			if (FlatIdent_31905 == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_31905 = 3;
			end
			if (FlatIdent_31905 == 3) then
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
		end
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_A9A3 = 0;
			while true do
				if (FlatIdent_A9A3 == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
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
			local FlatIdent_40CF = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_40CF == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_40CF = 1;
				end
				if (FlatIdent_40CF == 1) then
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
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_79536 = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_79536 == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
					if (FlatIdent_79536 == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_79536 = 3;
					end
					if (FlatIdent_79536 == 0) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_79536 = 1;
					end
					if (FlatIdent_79536 == 1) then
						Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							Inst[3] = gBits16();
							Inst[4] = gBits16();
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
						end
						FlatIdent_79536 = 2;
					end
				end
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
										local A = Inst[2];
										local Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
										local Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
									else
										local A = Inst[2];
										do
											return Unpack(Stk, A, A + Inst[3]);
										end
									end
								elseif (Enum > 2) then
									local FlatIdent_25DF3 = 0;
									local A;
									while true do
										if (FlatIdent_25DF3 == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_25DF3 = 1;
										end
										if (FlatIdent_25DF3 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_25DF3 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											FlatIdent_25DF3 = 3;
										end
										if (FlatIdent_25DF3 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_25DF3 = 2;
										end
										if (FlatIdent_25DF3 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											FlatIdent_25DF3 = 4;
										end
									end
								else
									do
										return Stk[Inst[2]];
									end
								end
							elseif (Enum <= 5) then
								if (Enum > 4) then
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
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								end
							elseif (Enum > 6) then
								do
									return;
								end
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
									local FlatIdent_494DF = 0;
									while true do
										if (FlatIdent_494DF == 0) then
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
						elseif (Enum <= 11) then
							if (Enum <= 9) then
								if (Enum > 8) then
									Stk[Inst[2]] = Stk[Inst[3]];
								else
									local FlatIdent_27404 = 0;
									local A;
									while true do
										if (FlatIdent_27404 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A]();
											break;
										end
									end
								end
							elseif (Enum == 10) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
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
									local FlatIdent_9622C = 0;
									while true do
										if (FlatIdent_9622C == 0) then
											Stk[CB] = R;
											VIP = Inst[3];
											break;
										end
									end
								else
									VIP = VIP + 1;
								end
							end
						elseif (Enum <= 13) then
							if (Enum == 12) then
								local A;
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
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
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							else
								local FlatIdent_2D88C = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_2D88C == 3) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_2D88C = 4;
									end
									if (FlatIdent_2D88C == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2D88C = 1;
									end
									if (6 == FlatIdent_2D88C) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
									if (FlatIdent_2D88C == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										FlatIdent_2D88C = 2;
									end
									if (FlatIdent_2D88C == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2D88C = 3;
									end
									if (5 == FlatIdent_2D88C) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_2D88C = 6;
									end
									if (4 == FlatIdent_2D88C) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_2D88C = 5;
									end
								end
							end
						elseif (Enum > 14) then
							if (Stk[Inst[2]] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
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
						end
					elseif (Enum <= 23) then
						if (Enum <= 19) then
							if (Enum <= 17) then
								if (Enum > 16) then
									Stk[Inst[2]] = Inst[3] ~= 0;
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
								end
							elseif (Enum == 18) then
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
						elseif (Enum <= 21) then
							if (Enum == 20) then
								local A = Inst[2];
								local Results = {Stk[A](Stk[A + 1])};
								local Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_2F37F = 0;
									while true do
										if (FlatIdent_2F37F == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							else
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
							end
						elseif (Enum == 22) then
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
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
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
								local FlatIdent_5998C = 0;
								local A;
								while true do
									if (FlatIdent_5998C == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_5998C = 8;
									end
									if (6 == FlatIdent_5998C) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_5998C = 7;
									end
									if (FlatIdent_5998C == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_5998C = 2;
									end
									if (FlatIdent_5998C == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_5998C = 4;
									end
									if (5 == FlatIdent_5998C) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_5998C = 6;
									end
									if (FlatIdent_5998C == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_5998C = 3;
									end
									if (FlatIdent_5998C == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
									if (FlatIdent_5998C == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_5998C = 1;
									end
									if (FlatIdent_5998C == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_5998C = 5;
									end
									if (FlatIdent_5998C == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_5998C = 9;
									end
								end
							end
						elseif (Enum > 26) then
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
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 29) then
						if (Enum > 28) then
							if (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
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
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 30) then
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
					elseif (Enum > 31) then
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
				elseif (Enum <= 49) then
					if (Enum <= 40) then
						if (Enum <= 36) then
							if (Enum <= 34) then
								if (Enum == 33) then
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
									local FlatIdent_28014 = 0;
									local A;
									while true do
										if (FlatIdent_28014 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
									end
								end
							elseif (Enum == 35) then
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
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum <= 38) then
							if (Enum > 37) then
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
								Stk[Inst[2]] = Upvalues[Inst[3]];
							end
						elseif (Enum > 39) then
							VIP = Inst[3];
						else
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						end
					elseif (Enum <= 44) then
						if (Enum <= 42) then
							if (Enum == 41) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_21449 = 0;
								local A;
								while true do
									if (FlatIdent_21449 == 7) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										break;
									end
									if (FlatIdent_21449 == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_21449 = 2;
									end
									if (FlatIdent_21449 == 0) then
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_21449 = 1;
									end
									if (FlatIdent_21449 == 5) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_21449 = 6;
									end
									if (FlatIdent_21449 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_21449 = 4;
									end
									if (FlatIdent_21449 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_21449 = 3;
									end
									if (FlatIdent_21449 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_21449 = 5;
									end
									if (FlatIdent_21449 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_21449 = 7;
									end
								end
							end
						elseif (Enum == 43) then
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
						else
							local A = Inst[2];
							local B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						end
					elseif (Enum <= 46) then
						if (Enum > 45) then
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local NewProto = Proto[Inst[3]];
							local NewUvals;
							local Indexes = {};
							NewUvals = Setmetatable({}, {__index=function(_, Key)
								local Val = Indexes[Key];
								return Val[1][Val[2]];
							end,__newindex=function(_, Key, Value)
								local Val = Indexes[Key];
								Val[1][Val[2]] = Value;
							end});
							for Idx = 1, Inst[4] do
								VIP = VIP + 1;
								local Mvm = Instr[VIP];
								if (Mvm[1] == 9) then
									Indexes[Idx - 1] = {Stk,Mvm[3]};
								else
									Indexes[Idx - 1] = {Upvalues,Mvm[3]};
								end
								Lupvals[#Lupvals + 1] = Indexes;
							end
							Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
						end
					elseif (Enum <= 47) then
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
					elseif (Enum > 48) then
						Stk[Inst[2]] = Inst[3];
					elseif (Inst[2] == Stk[Inst[4]]) then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 57) then
					if (Enum <= 53) then
						if (Enum <= 51) then
							if (Enum > 50) then
								local A = Inst[2];
								Stk[A](Stk[A + 1]);
							else
								local FlatIdent_634AF = 0;
								local A;
								while true do
									if (FlatIdent_634AF == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_634AF = 5;
									end
									if (FlatIdent_634AF == 6) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_634AF = 7;
									end
									if (FlatIdent_634AF == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_634AF = 4;
									end
									if (7 == FlatIdent_634AF) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
									if (FlatIdent_634AF == 5) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_634AF = 6;
									end
									if (FlatIdent_634AF == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_634AF = 2;
									end
									if (FlatIdent_634AF == 0) then
										A = nil;
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										FlatIdent_634AF = 1;
									end
									if (FlatIdent_634AF == 2) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_634AF = 3;
									end
								end
							end
						elseif (Enum == 52) then
							Stk[Inst[2]] = {};
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
						end
					elseif (Enum <= 55) then
						if (Enum == 54) then
							local FlatIdent_44603 = 0;
							local A;
							while true do
								if (2 == FlatIdent_44603) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_44603 = 3;
								end
								if (4 == FlatIdent_44603) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_44603 = 5;
								end
								if (1 == FlatIdent_44603) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_44603 = 2;
								end
								if (FlatIdent_44603 == 5) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_44603 == 0) then
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_44603 = 1;
								end
								if (FlatIdent_44603 == 3) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_44603 = 4;
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
					elseif (Enum == 56) then
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
					end
				elseif (Enum <= 61) then
					if (Enum <= 59) then
						if (Enum > 58) then
							local FlatIdent_8FBAE = 0;
							local A;
							while true do
								if (4 == FlatIdent_8FBAE) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_8FBAE == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_8FBAE = 4;
								end
								if (FlatIdent_8FBAE == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_8FBAE = 2;
								end
								if (FlatIdent_8FBAE == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_8FBAE = 3;
								end
								if (FlatIdent_8FBAE == 0) then
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_8FBAE = 1;
								end
							end
						else
							local FlatIdent_21CA5 = 0;
							local A;
							while true do
								if (FlatIdent_21CA5 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_21CA5 = 8;
								end
								if (0 == FlatIdent_21CA5) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_21CA5 = 1;
								end
								if (FlatIdent_21CA5 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_21CA5 = 5;
								end
								if (FlatIdent_21CA5 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_21CA5 = 7;
								end
								if (FlatIdent_21CA5 == 5) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_21CA5 = 6;
								end
								if (FlatIdent_21CA5 == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_21CA5 = 4;
								end
								if (2 == FlatIdent_21CA5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_21CA5 = 3;
								end
								if (FlatIdent_21CA5 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_21CA5 = 2;
								end
								if (FlatIdent_21CA5 == 8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_21CA5 = 9;
								end
								if (9 == FlatIdent_21CA5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									break;
								end
							end
						end
					elseif (Enum == 60) then
						local FlatIdent_5AA23 = 0;
						local A;
						local Cls;
						while true do
							if (FlatIdent_5AA23 == 0) then
								A = Inst[2];
								Cls = {};
								FlatIdent_5AA23 = 1;
							end
							if (FlatIdent_5AA23 == 1) then
								for Idx = 1, #Lupvals do
									local List = Lupvals[Idx];
									for Idz = 0, #List do
										local FlatIdent_3F15E = 0;
										local Upv;
										local NStk;
										local DIP;
										while true do
											if (FlatIdent_3F15E == 1) then
												DIP = Upv[2];
												if ((NStk == Stk) and (DIP >= A)) then
													local FlatIdent_229D1 = 0;
													while true do
														if (FlatIdent_229D1 == 0) then
															Cls[DIP] = NStk[DIP];
															Upv[1] = Cls;
															break;
														end
													end
												end
												break;
											end
											if (FlatIdent_3F15E == 0) then
												Upv = List[Idz];
												NStk = Upv[1];
												FlatIdent_3F15E = 1;
											end
										end
									end
								end
								break;
							end
						end
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
				elseif (Enum <= 63) then
					if (Enum > 62) then
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
					else
						Stk[Inst[2]] = Env[Inst[3]];
					end
				elseif (Enum <= 64) then
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
				elseif (Enum == 65) then
					Stk[Inst[2]]();
				else
					local A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4C3O00028O00026O00224003043O0053697A6503053O005544696D322O033O006E6577026O66D63F026O33C33F03083O00506F736974696F6E029A5O99E13F026O66E63F03103O004261636B67726F756E64436F6C6F723303063O00436F6C6F723303073O0066726F6D524742026O00394003043O005465787403093O00436865636B204B657903083O005465787453697A65026O003240030A3O0054657874436F6C6F7233025O00C0624003063O00506172656E74026O002440026O00084003113O004D6F75736542752O746F6E31436C69636B03073O00436F2O6E65637403083O00496E7374616E636503093O00546578744C6162656C026O00F03F026O003E40029A5O99A93F030A3O004B65792053797374656D026O001040026O002E4003093O005363722O656E47756903043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030C3O0057616974466F724368696C6403093O00506C61796572477569027O0040026O00E03F030B3O00416E63686F72506F696E7403073O00566563746F723203053O004672616D65026O007940025O00C07240026O00204003083O005549436F726E6572030C3O00436F726E657252616469757303043O005544696D026O001440030A3O005465787442752O746F6E026O002640030F3O00426F7264657253697A65506978656C03063O004163746976652O0103093O004472612O6761626C65026O001C40029A5O99B93F03073O00476574204B6579026O001840030F3O00506C616365686F6C64657254657874030C3O00456E746572204B65793O2E034O00025O00E06F4003163O004261636B67726F756E645472616E73706172656E6379029A5O99C93F031E3O00456E746572204B657920546F20412O63652O732054686520536372697074026O004440026O0044C003023O00C397030A3O00546578745363616C6564026O002A4003073O0054657874426F78029A5O99E93F029A5O99D93F009D012O0012313O00014O003F0001000E3O00261D3O0026000100020004283O0026000100123E000F00043O002035000F000F000500122O001000063O00122O001100013O00122O001200073O00122O001300016O000F0013000200102O000B0003000F00122O000F00043O00202O000F000F000500122O001000093O00121E001100013O00122O0012000A3O00122O001300016O000F0013000200102O000B0008000F00122O000F000C3O00202O000F000F000D00122O0010000E3O00122O0011000E3O00122O0012000E4O0042000F00120002001024000B000B000F00300C000B000F001000302O000B0011001200122O000F000C3O00202O000F000F000D00122O001000143O00122O001100143O00122O001200146O000F0012000200102O000B0013000F00102O000B001500020012313O00163O00261D3O0046000100170004283O00460001001024000400150002002004000F0004001800202C000F000F001900062D00113O000100012O00093O00014O000E000F0011000100122O000F001A3O00202O000F000F000500122O0010001B6O000F000200024O0005000F3O00122O000F00043O00202O000F000F000500122O0010001C3O00122O001100013O001231001200013O0012050013001D6O000F0013000200102O00050003000F00122O000F00043O00202O000F000F000500122O001000013O00122O001100013O00122O0012001E3O00122O001300016O000F0013000200102400050008000F00300A0005000F001F00300A0005001100120012313O00203O00261D3O0085000100010004283O00850001001231000F00013O00261D000F0054000100170004283O0054000100123E0010000C3O00203600100010000D00122O001100213O00122O001200213O00122O001300216O00100013000200102O0002000B001000124O001C3O00044O0085000100261D000F0063000100010004283O0063000100123E0010001A3O00200D00100010000500122O001100226O0010000200024O000100103O00122O001000233O00202O00100010002400202O00100010002500202O00100010002600122O001200276O001000120002001024000100150010001231000F001C3O00261D000F0074000100280004283O0074000100123E001000043O00203500100010000500122O001100293O00122O001200013O00122O001300293O00122O001400016O00100014000200102O00020008001000122O0010002B3O00202O00100010000500122O001100293O001231001200294O00420010001200020010240002002A0010001231000F00173O00261D000F00490001001C0004283O0049000100123E0010001A3O00203700100010000500122O0011002C6O0010000200024O000200103O00122O001000043O00202O00100010000500122O001100013O00122O0012002D3O00122O001300013O00122O0014002E4O0042001000140002001024000200030010001231000F00283O0004283O0049000100261D3O00A20001002F0004283O00A2000100300A00090011001200123A000F000C3O00202O000F000F000D00122O001000143O00122O001100143O00122O001200146O000F0012000200102O00090013000F00102O00090015000200122O000F001A3O00202O000F000F0005001231001000304O0032000F000200024O000A000F3O00122O000F00323O00202O000F000F000500122O001000013O00122O001100336O000F0011000200102O000A0031000F00102O000A0015000900122O000F001A3O002004000F000F0005001231001000344O0022000F000200022O0009000B000F3O0012313O00023O00261D3O00B8000100160004283O00B8000100123E000F001A3O00202F000F000F000500122O001000306O000F000200024O000C000F3O00122O000F00323O00202O000F000F000500122O001000013O00122O001100336O000F0011000200102O000C0031000F001024000C0015000B002004000F0009001800202C000F000F0019000227001100014O002E000F001100012O003F000D000D3O000227000D00024O003F000E000E3O0012313O00353O00261D3O00CB0001001C0004283O00CB000100300A00020036000100301B00020037003800302O00020039003800102O00020015000100122O000F001A3O00202O000F000F000500122O001000306O000F000200024O0003000F3O00122O000F00323O00202O000F000F0005001231001000013O001221001100166O000F0011000200102O00030031000F00102O00030015000200124O00283O00261D3O00F20001003A0004283O00F2000100123E000F00323O002019000F000F000500122O001000013O00122O001100336O000F0011000200102O00080031000F00102O00080015000700122O000F001A3O00202O000F000F000500122O001000346O000F000200022O00090009000F3O00122B000F00043O00202O000F000F000500122O001000063O00122O001100013O00122O001200073O00122O001300016O000F0013000200102O00090003000F00122O000F00043O00202O000F000F00050012310010003B3O00121E001100013O00122O0012000A3O00122O001300016O000F0013000200102O00090008000F00122O000F000C3O00202O000F000F000D00122O0010000E3O00122O0011000E3O00122O0012000E4O0042000F001200020010240009000B000F00300A0009000F003C0012313O002F3O00261D3O00FE000100350004283O00FE000100062D000E0003000100012O00093O000D3O002004000F000B001800202C000F000F001900062D00110004000100032O00093O00074O00093O000E4O00093O00014O002E000F001100010004283O009B2O0100261D3O00182O01003D0004283O00182O0100123E000F000C3O002018000F000F000D00122O0010000E3O00122O0011000E3O00122O0012000E6O000F0012000200102O0007000B000F00302O0007003E003F00302O0007000F004000302O00070011001200122O000F000C3O002004000F000F000D00122A001000413O00122O001100413O00122O001200416O000F0012000200102O00070013000F00102O00070015000200122O000F001A3O00202O000F000F000500122O001000306O000F000200022O00090008000F3O0012313O003A3O00261D3O00482O0100200004283O00482O01001231000F00013O00261D000F00262O0100010004283O00262O0100123E0010000C3O00202600100010000D00122O001100413O00122O001200413O00122O001300416O00100013000200102O00050013001000302O00050042001C00122O000F001C3O00261D000F00392O0100280004283O00392O0100123E001000043O00203500100010000500122O0011001C3O00122O001200013O00122O001300013O00122O0014001D6O00100014000200102O00060003001000122O001000043O00202O00100010000500122O001100013O001231001200013O001217001300433O00122O001400016O00100014000200102O00060008001000122O000F00173O00261D000F003E2O0100170004283O003E2O0100300A0006000F00440012313O00333O0004283O00482O0100261D000F001B2O01001C0004283O001B2O0100102400050015000200121C0010001A3O00202O00100010000500122O0011001B6O0010000200024O000600103O00122O000F00283O00044O001B2O0100261D3O00782O0100280004283O00782O01001231000F00013O00261D000F005B2O0100010004283O005B2O0100123E0010001A3O00203700100010000500122O001100346O0010000200024O000400103O00122O001000043O00202O00100010000500122O001100013O00122O001200453O00122O001300013O00122O001400454O0042001000140002001024000400030010001231000F001C3O00261D000F00672O01001C0004283O00672O0100123E001000043O00201600100010000500122O0011001C3O00122O001200463O00122O001300013O00122O001400016O00100014000200102O00040008001000302O00040042001C00122O000F00283O00261D000F00722O0100170004283O00722O0100123E0010000C3O00203600100010000D00122O001100143O00122O001200143O00122O001300146O00100013000200102O00040013001000124O00173O00044O00782O0100261D000F004B2O0100280004283O004B2O0100300A0004000F004700300A000400480038001231000F00173O0004283O004B2O0100261D3O0002000100330004283O0002000100300A000600110049001223000F000C3O00202O000F000F000D00122O001000143O00122O001100143O00122O001200146O000F0012000200102O00060013000F00302O00060042001C00102O00060015000200122O000F001A3O002037000F000F000500122O0010004A6O000F000200024O0007000F3O00122O000F00043O00202O000F000F000500122O0010004B3O00122O001100013O00122O001200433O00122O001300014O0042000F0013000200102400070003000F002O12000F00043O00202O000F000F000500122O0010003B3O00122O001100013O00122O0012004C3O00122O001300016O000F0013000200102O00070008000F00124O003D3O00044O000200012O003C8O00073O00013O00053O00013O0003073O0044657374726F7900044O00257O00202C5O00012O00333O000200012O00073O00017O00023O00030C3O00736574636C6970626F617264031F3O004B4559204953204F4E4C5920474956454E20544F2057484954454C4953542E00043O00123E3O00013O001231000100024O00333O000200012O00073O00017O00093O00028O00026O00F03F03063O00676D617463682O033O0025532B03053O007461626C6503063O00696E7365727403043O0067616D6503073O00482O747047657403483O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5468656F62667573696361746F726775792F4B4559532F6D61696E2F5343524950542E747874001C3O0012313O00014O003F000100023O00261D3O0010000100020004283O0010000100202C000300010003001231000500046O0003000500050004283O000D000100123E000700053O0020040007000700062O0009000800024O0009000900064O002E00070009000100060B00030008000100010004283O000800012O0002000200023O00261D3O0002000100010004283O0002000100123E000300073O00201500030003000800122O000500096O0003000500024O000100036O00038O000200033O00124O00023O00044O000200012O00073O00017O00033O00028O0003053O007061697273026O00F03F011D3O001231000100014O003F000200023O001231000300013O00261D00030003000100010004283O0003000100261D00010015000100010004283O001500012O002500046O00060004000100024O000200043O00122O000400026O000500026O00040002000600044O0012000100060F3O0012000100080004283O001200012O0011000900014O0002000900023O00060B0004000E000100020004283O000E0001001231000100033O00261D00010002000100030004283O000200012O001100046O0002000400023O0004283O000200010004283O000300010004283O000200012O00073O00017O000D3O00028O0003043O0054657874027O00400362052O009O202O202O2D2047756920746F204C75610A2O2D2056657273696F6E3A20332E322O0A2O2D20496E7374616E6365733A2O0A6C6F63616C205363722O656E477569203D20496E7374616E63652E6E657728225363722O656E47756922290A6C6F63616C204672616D65203D20496E7374616E63652E6E657728224672616D6522290A6C6F63616C205465787442752O746F6E203D20496E7374616E63652E6E657728225465787442752O746F6E22292O0A2O2D50726F706572746965733A2O0A5363722O656E4775692E506172656E74203D2067616D652E506C61796572732E4C6F63616C506C617965723A57616974466F724368696C642822506C6179657247756922290A5363722O656E4775692E5A496E6465784265686176696F72203D20456E756D2E5A496E6465784265686176696F722E5369626C696E672O0A4672616D652E506172656E74203D205363722O656E4775690A4672616D652E4261636B67726F756E64436F6C6F7233203D20436F6C6F72332E66726F6D52474228322O352C20322O352C20322O35290A4672616D652E426F72646572436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A4672616D652E426F7264657253697A65506978656C203D20300A4672616D652E53697A65203D205544696D322E6E657728312C20302C20302E3233383437332O37332C2030292O0A5465787442752O746F6E2E506172656E74203D204672616D650A5465787442752O746F6E2E4261636B67726F756E64436F6C6F7233203D20436F6C6F72332E66726F6D52474228322O352C20322O352C20322O35290A5465787442752O746F6E2E426F72646572436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A5465787442752O746F6E2E426F7264657253697A65506978656C203D20300A5465787442752O746F6E2E506F736974696F6E203D205544696D322E6E657728302E32352C20302C20302E32345O392O352C2030290A5465787442752O746F6E2E53697A65203D205544696D322E6E657728302E352C20302C20302E352C2030290A5465787442752O746F6E2E466F6E74203D20456E756D2E466F6E742E536F7572636553616E730A5465787442752O746F6E2E54657874203D2022736372697074207374692O6C206F6E20646576656C6F706D656E742C20636C69636B206D6520746F20636C6F7365220A5465787442752O746F6E2E54657874436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A5465787442752O746F6E2E5465787453697A65203D2031342E3O302O0A2O2D20536372697074733A2O0A6C6F63616C2066756E6374696F6E20595A465246415F66616B655F7363726970742829202O2D205465787442752O746F6E2E4C6F63616C536372697074200A096C6F63616C20736372697074203D20496E7374616E63652E6E657728274C6F63616C536372697074272C205465787442752O746F6E292O0A096C6F63616C2042752O746F6E203D207363726970742E506172656E740A090A096C6F63616C2066756E6374696F6E2064657374726F794772616E64706172656E7428290A2O0969662042752O746F6E2E506172656E7420616E642042752O746F6E2E506172656E742E506172656E74207468656E0A3O0942752O746F6E2E506172656E742E506172656E743A44657374726F7928290A2O09656E640A09656E640A090A0942752O746F6E2E4D6F75736542752O746F6E31436C69636B3A436F2O6E6563742864657374726F794772616E64706172656E74290A090A656E640A636F726F7574696E652E7772617028595A465246415F66616B655F7363726970742928292O0A8O20030A3O006C6F6164737472696E67030F3O00506C616365686F6C64657254657874030C3O00436F2O72656374204B657921034O00026O00F03F03043O007761697403073O0044657374726F79030C3O00456E746572204B65793O2E03173O00496E76616C6964206B65792E2054727920616761696E2E00413O0012313O00014O003F000100013O00261D3O0002000100010004283O000200012O002500025O00201F0001000200024O000200016O000300016O00020002000200062O0002002700013O0004283O00270001001231000200014O003F000300033O000E3000030015000100020004283O00150001001231000300043O001203000400056O000500036O0004000200024O00040001000100044O0040000100261D0002001C000100010004283O001C00012O002500045O00300A0004000600072O002500045O00300A000400020008001231000200093O00261D0002000D000100090004283O000D000100123E0004000A3O00123D000500096O0004000200014O000400023O00202O00040004000B4O00040002000100122O000200033O00044O000D00010004283O00400001001231000200014O003F000300033O00261D00020029000100010004283O00290001001231000300013O00261D00030034000100090004283O0034000100123E0004000A3O00123B000500096O0004000200014O00045O00302O00040006000C00044O0040000100261D0003002C000100010004283O002C00012O002500045O00302000040006000D4O00045O00302O00040002000800122O000300093O00044O002C00010004283O004000010004283O002900010004283O004000010004283O000200012O00073O00017O00", GetFEnv(), ...);
