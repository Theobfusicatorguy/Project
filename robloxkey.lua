-- STOP YOU SKID
-- LEARN LUA INSTEAD. 
--[[



STOP SCROLLING

































STILL?







































ok chill, im sorry.








































































































1 mile



















































































































2 miles






































































































ITS BEEN 3 MILES, 





























































End...







































































ITS ALREADY THE END...

]]--
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
			local FlatIdent_7D3C9 = 0;
			while true do
				if (0 == FlatIdent_7D3C9) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local FlatIdent_76979 = 0;
			local a;
			while true do
				if (FlatIdent_76979 == 0) then
					a = Char(StrToNumber(byte, 16));
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
					break;
				end
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
			local FlatIdent_5CC3B = 0;
			local Plc;
			while true do
				if (0 == FlatIdent_5CC3B) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local FlatIdent_12703 = 0;
		local a;
		while true do
			if (FlatIdent_12703 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_12703 = 1;
			end
			if (FlatIdent_12703 == 1) then
				return a;
			end
		end
	end
	local function gBits16()
		local FlatIdent_475BC = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_475BC == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_475BC = 1;
			end
			if (FlatIdent_475BC == 1) then
				return (b * 256) + a;
			end
		end
	end
	local function gBits32()
		local FlatIdent_43862 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (0 == FlatIdent_43862) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_43862 = 1;
			end
			if (FlatIdent_43862 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
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
				local FlatIdent_781F8 = 0;
				while true do
					if (FlatIdent_781F8 == 0) then
						Exponent = 1;
						IsNormal = 0;
						break;
					end
				end
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local FlatIdent_6FA1 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_6FA1 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_6FA1 = 2;
			end
			if (FlatIdent_6FA1 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_6FA1 = 3;
			end
			if (0 == FlatIdent_6FA1) then
				Str = nil;
				if not Len then
					local FlatIdent_74B46 = 0;
					while true do
						if (FlatIdent_74B46 == 0) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_6FA1 = 1;
			end
			if (FlatIdent_6FA1 == 3) then
				return Concat(FStr);
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
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_703C8 = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_703C8 == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_703C8 = 3;
					end
					if (FlatIdent_703C8 == 0) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_703C8 = 1;
					end
					if (FlatIdent_703C8 == 1) then
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
						FlatIdent_703C8 = 2;
					end
					if (FlatIdent_703C8 == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
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
				if (Enum <= 36) then
					if (Enum <= 17) then
						if (Enum <= 8) then
							if (Enum <= 3) then
								if (Enum <= 1) then
									if (Enum > 0) then
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
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local FlatIdent_1B1BA = 0;
										local A;
										while true do
											if (8 == FlatIdent_1B1BA) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1B1BA = 9;
											end
											if (FlatIdent_1B1BA == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_1B1BA = 4;
											end
											if (FlatIdent_1B1BA == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1B1BA = 1;
											end
											if (FlatIdent_1B1BA == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_1B1BA == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1B1BA = 8;
											end
											if (FlatIdent_1B1BA == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_1B1BA = 6;
											end
											if (FlatIdent_1B1BA == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1B1BA = 2;
											end
											if (6 == FlatIdent_1B1BA) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_1B1BA = 7;
											end
											if (FlatIdent_1B1BA == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_1B1BA = 5;
											end
											if (FlatIdent_1B1BA == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1B1BA = 3;
											end
										end
									end
								elseif (Enum == 2) then
									local A = Inst[2];
									local C = Inst[4];
									local CB = A + 2;
									local Result = {Stk[A](Stk[A + 1], Stk[CB])};
									for Idx = 1, C do
										Stk[CB + Idx] = Result[Idx];
									end
									local R = Result[1];
									if R then
										local FlatIdent_6F3E4 = 0;
										while true do
											if (FlatIdent_6F3E4 == 0) then
												Stk[CB] = R;
												VIP = Inst[3];
												break;
											end
										end
									else
										VIP = VIP + 1;
									end
								else
									local FlatIdent_8D1A5 = 0;
									local A;
									while true do
										if (FlatIdent_8D1A5 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8D1A5 = 1;
										end
										if (4 == FlatIdent_8D1A5) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8D1A5 = 5;
										end
										if (6 == FlatIdent_8D1A5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_8D1A5 = 7;
										end
										if (FlatIdent_8D1A5 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8D1A5 = 3;
										end
										if (FlatIdent_8D1A5 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8D1A5 = 2;
										end
										if (FlatIdent_8D1A5 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											break;
										end
										if (3 == FlatIdent_8D1A5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_8D1A5 = 4;
										end
										if (5 == FlatIdent_8D1A5) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_8D1A5 = 6;
										end
									end
								end
							elseif (Enum <= 5) then
								if (Enum > 4) then
									Stk[Inst[2]] = Env[Inst[3]];
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
							elseif (Enum <= 6) then
								if (Inst[2] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 7) then
								local NewProto = Proto[Inst[3]];
								local NewUvals;
								local Indexes = {};
								NewUvals = Setmetatable({}, {__index=function(_, Key)
									local FlatIdent_2E9CB = 0;
									local Val;
									while true do
										if (FlatIdent_2E9CB == 0) then
											Val = Indexes[Key];
											return Val[1][Val[2]];
										end
									end
								end,__newindex=function(_, Key, Value)
									local FlatIdent_95405 = 0;
									local Val;
									while true do
										if (FlatIdent_95405 == 0) then
											Val = Indexes[Key];
											Val[1][Val[2]] = Value;
											break;
										end
									end
								end});
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
							else
								Stk[Inst[2]]();
							end
						elseif (Enum <= 12) then
							if (Enum <= 10) then
								if (Enum > 9) then
									local A = Inst[2];
									local Results = {Stk[A](Stk[A + 1])};
									local Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								else
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum > 11) then
								if (Stk[Inst[2]] == Stk[Inst[4]]) then
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
							end
						elseif (Enum <= 14) then
							if (Enum > 13) then
								do
									return;
								end
							else
								local FlatIdent_8BF78 = 0;
								local A;
								while true do
									if (0 == FlatIdent_8BF78) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8BF78 = 1;
									end
									if (FlatIdent_8BF78 == 3) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_8BF78 = 4;
									end
									if (FlatIdent_8BF78 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8BF78 = 3;
									end
									if (FlatIdent_8BF78 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_8BF78 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_8BF78 = 5;
									end
									if (FlatIdent_8BF78 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8BF78 = 2;
									end
								end
							end
						elseif (Enum <= 15) then
							local FlatIdent_58A9D = 0;
							local A;
							while true do
								if (0 == FlatIdent_58A9D) then
									A = Inst[2];
									do
										return Unpack(Stk, A, Top);
									end
									break;
								end
							end
						elseif (Enum > 16) then
							VIP = Inst[3];
						else
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						end
					elseif (Enum <= 26) then
						if (Enum <= 21) then
							if (Enum <= 19) then
								if (Enum == 18) then
									local FlatIdent_5EF9 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_5EF9 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5EF9 = 4;
										end
										if (FlatIdent_5EF9 == 2) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5EF9 = 3;
										end
										if (FlatIdent_5EF9 == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_5EF9 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5EF9 = 2;
										end
										if (0 == FlatIdent_5EF9) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5EF9 = 1;
										end
										if (4 == FlatIdent_5EF9) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5EF9 = 5;
										end
									end
								else
									local FlatIdent_29E69 = 0;
									local A;
									while true do
										if (FlatIdent_29E69 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_29E69 = 7;
										end
										if (FlatIdent_29E69 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_29E69 = 3;
										end
										if (FlatIdent_29E69 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_29E69 = 4;
										end
										if (0 == FlatIdent_29E69) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_29E69 = 1;
										end
										if (FlatIdent_29E69 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_29E69 = 9;
										end
										if (FlatIdent_29E69 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_29E69 = 2;
										end
										if (FlatIdent_29E69 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_29E69 = 5;
										end
										if (FlatIdent_29E69 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (7 == FlatIdent_29E69) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_29E69 = 8;
										end
										if (FlatIdent_29E69 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_29E69 = 6;
										end
									end
								end
							elseif (Enum > 20) then
								local FlatIdent_3C8BC = 0;
								local Edx;
								local Results;
								local A;
								while true do
									if (FlatIdent_3C8BC == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_3C8BC = 3;
									end
									if (FlatIdent_3C8BC == 7) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_3C8BC == 0) then
										Edx = nil;
										Results = nil;
										A = nil;
										FlatIdent_3C8BC = 1;
									end
									if (FlatIdent_3C8BC == 5) then
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Stk[A + 1])};
										FlatIdent_3C8BC = 6;
									end
									if (FlatIdent_3C8BC == 1) then
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										FlatIdent_3C8BC = 2;
									end
									if (FlatIdent_3C8BC == 6) then
										Edx = 0;
										for Idx = A, Inst[4] do
											local FlatIdent_FA88 = 0;
											while true do
												if (FlatIdent_FA88 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										FlatIdent_3C8BC = 7;
									end
									if (FlatIdent_3C8BC == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_3C8BC = 5;
									end
									if (FlatIdent_3C8BC == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_3C8BC = 4;
									end
								end
							else
								local FlatIdent_904EC = 0;
								local A;
								while true do
									if (FlatIdent_904EC == 7) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										break;
									end
									if (FlatIdent_904EC == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_904EC = 3;
									end
									if (FlatIdent_904EC == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_904EC = 4;
									end
									if (FlatIdent_904EC == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_904EC = 7;
									end
									if (FlatIdent_904EC == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_904EC = 2;
									end
									if (FlatIdent_904EC == 5) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_904EC = 6;
									end
									if (FlatIdent_904EC == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_904EC = 5;
									end
									if (FlatIdent_904EC == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_904EC = 1;
									end
								end
							end
						elseif (Enum <= 23) then
							if (Enum == 22) then
								local FlatIdent_7EE98 = 0;
								local A;
								while true do
									if (FlatIdent_7EE98 == 0) then
										A = Inst[2];
										do
											return Unpack(Stk, A, A + Inst[3]);
										end
										break;
									end
								end
							else
								local FlatIdent_285D = 0;
								local A;
								while true do
									if (FlatIdent_285D == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_285D = 4;
									end
									if (FlatIdent_285D == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_285D = 1;
									end
									if (FlatIdent_285D == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_285D = 3;
									end
									if (FlatIdent_285D == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_285D = 5;
									end
									if (FlatIdent_285D == 5) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										break;
									end
									if (FlatIdent_285D == 1) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_285D = 2;
									end
								end
							end
						elseif (Enum <= 24) then
							local FlatIdent_580CB = 0;
							local A;
							while true do
								if (FlatIdent_580CB == 5) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_580CB = 6;
								end
								if (FlatIdent_580CB == 0) then
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_580CB = 1;
								end
								if (FlatIdent_580CB == 7) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_580CB == 1) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_580CB = 2;
								end
								if (FlatIdent_580CB == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_580CB = 4;
								end
								if (4 == FlatIdent_580CB) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_580CB = 5;
								end
								if (FlatIdent_580CB == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_580CB = 7;
								end
								if (FlatIdent_580CB == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_580CB = 3;
								end
							end
						elseif (Enum > 25) then
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
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						end
					elseif (Enum <= 31) then
						if (Enum <= 28) then
							if (Enum == 27) then
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
							else
								local FlatIdent_259C6 = 0;
								local A;
								while true do
									if (FlatIdent_259C6 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_259C6 = 4;
									end
									if (FlatIdent_259C6 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_259C6 = 1;
									end
									if (FlatIdent_259C6 == 5) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_259C6 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_259C6 = 3;
									end
									if (FlatIdent_259C6 == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_259C6 = 2;
									end
									if (FlatIdent_259C6 == 4) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_259C6 = 5;
									end
								end
							end
						elseif (Enum <= 29) then
							local A = Inst[2];
							Stk[A](Stk[A + 1]);
						elseif (Enum > 30) then
							local FlatIdent_91B54 = 0;
							while true do
								if (FlatIdent_91B54 == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_91B54 = 3;
								end
								if (FlatIdent_91B54 == 3) then
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_91B54 == 0) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_91B54 = 1;
								end
								if (FlatIdent_91B54 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_91B54 = 2;
								end
							end
						else
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
						end
					elseif (Enum <= 33) then
						if (Enum == 32) then
							local FlatIdent_15A17 = 0;
							while true do
								if (FlatIdent_15A17 == 0) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_15A17 = 1;
								end
								if (FlatIdent_15A17 == 1) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_15A17 = 2;
								end
								if (FlatIdent_15A17 == 2) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_15A17 = 3;
								end
								if (FlatIdent_15A17 == 3) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_15A17 = 4;
								end
								if (FlatIdent_15A17 == 4) then
									VIP = Inst[3];
									break;
								end
							end
						else
							local A = Inst[2];
							Stk[A] = Stk[A]();
						end
					elseif (Enum <= 34) then
						do
							return Stk[Inst[2]];
						end
					elseif (Enum > 35) then
						local FlatIdent_5D802 = 0;
						local A;
						while true do
							if (FlatIdent_5D802 == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5D802 = 4;
							end
							if (1 == FlatIdent_5D802) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_5D802 = 2;
							end
							if (FlatIdent_5D802 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_5D802 = 7;
							end
							if (FlatIdent_5D802 == 0) then
								A = nil;
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5D802 = 1;
							end
							if (FlatIdent_5D802 == 5) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_5D802 = 6;
							end
							if (FlatIdent_5D802 == 7) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								break;
							end
							if (FlatIdent_5D802 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_5D802 = 3;
							end
							if (FlatIdent_5D802 == 4) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_5D802 = 5;
							end
						end
					else
						local FlatIdent_3B868 = 0;
						local A;
						while true do
							if (FlatIdent_3B868 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_3B868 = 7;
							end
							if (FlatIdent_3B868 == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_3B868 = 2;
							end
							if (FlatIdent_3B868 == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_3B868 = 4;
							end
							if (4 == FlatIdent_3B868) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_3B868 = 5;
							end
							if (FlatIdent_3B868 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_3B868 = 6;
							end
							if (2 == FlatIdent_3B868) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_3B868 = 3;
							end
							if (9 == FlatIdent_3B868) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								break;
							end
							if (FlatIdent_3B868 == 7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_3B868 = 8;
							end
							if (FlatIdent_3B868 == 8) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_3B868 = 9;
							end
							if (FlatIdent_3B868 == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_3B868 = 1;
							end
						end
					end
				elseif (Enum <= 54) then
					if (Enum <= 45) then
						if (Enum <= 40) then
							if (Enum <= 38) then
								if (Enum == 37) then
									local A;
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
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								else
									local FlatIdent_37DBD = 0;
									local A;
									while true do
										if (FlatIdent_37DBD == 0) then
											A = Inst[2];
											do
												return Stk[A](Unpack(Stk, A + 1, Inst[3]));
											end
											break;
										end
									end
								end
							elseif (Enum == 39) then
								local FlatIdent_624DF = 0;
								local A;
								while true do
									if (FlatIdent_624DF == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_624DF = 4;
									end
									if (FlatIdent_624DF == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_624DF = 2;
									end
									if (FlatIdent_624DF == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_624DF = 1;
									end
									if (FlatIdent_624DF == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_624DF = 5;
									end
									if (FlatIdent_624DF == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_624DF = 3;
									end
									if (FlatIdent_624DF == 5) then
										Stk[A] = Stk[A](Stk[A + 1]);
										break;
									end
								end
							else
								local FlatIdent_8EA6E = 0;
								local A;
								while true do
									if (FlatIdent_8EA6E == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8EA6E = 4;
									end
									if (4 == FlatIdent_8EA6E) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_8EA6E = 5;
									end
									if (FlatIdent_8EA6E == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										break;
									end
									if (FlatIdent_8EA6E == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8EA6E = 3;
									end
									if (FlatIdent_8EA6E == 0) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8EA6E = 1;
									end
									if (FlatIdent_8EA6E == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_8EA6E = 7;
									end
									if (5 == FlatIdent_8EA6E) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_8EA6E = 6;
									end
									if (FlatIdent_8EA6E == 1) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_8EA6E = 2;
									end
								end
							end
						elseif (Enum <= 42) then
							if (Enum > 41) then
								local FlatIdent_74EA4 = 0;
								local A;
								while true do
									if (FlatIdent_74EA4 == 0) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_74EA4 = 1;
									end
									if (FlatIdent_74EA4 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_74EA4 == 2) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										FlatIdent_74EA4 = 3;
									end
									if (FlatIdent_74EA4 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_74EA4 = 2;
									end
									if (FlatIdent_74EA4 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										FlatIdent_74EA4 = 4;
									end
								end
							else
								local FlatIdent_55482 = 0;
								local B;
								local K;
								while true do
									if (FlatIdent_55482 == 0) then
										B = Inst[3];
										K = Stk[B];
										FlatIdent_55482 = 1;
									end
									if (FlatIdent_55482 == 1) then
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										break;
									end
								end
							end
						elseif (Enum <= 43) then
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
							Stk[Inst[2]] = Inst[3];
						elseif (Enum == 44) then
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
						elseif Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 49) then
						if (Enum <= 47) then
							if (Enum == 46) then
								local FlatIdent_9010 = 0;
								local A;
								while true do
									if (FlatIdent_9010 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_9010 = 6;
									end
									if (FlatIdent_9010 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_9010 = 2;
									end
									if (3 == FlatIdent_9010) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_9010 = 4;
									end
									if (2 == FlatIdent_9010) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_9010 = 3;
									end
									if (FlatIdent_9010 == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										break;
									end
									if (FlatIdent_9010 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_9010 = 5;
									end
									if (FlatIdent_9010 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_9010 = 9;
									end
									if (7 == FlatIdent_9010) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_9010 = 8;
									end
									if (6 == FlatIdent_9010) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_9010 = 7;
									end
									if (FlatIdent_9010 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_9010 = 1;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							end
						elseif (Enum == 48) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						else
							Stk[Inst[2]] = {};
						end
					elseif (Enum <= 51) then
						if (Enum > 50) then
							Stk[Inst[2]] = Stk[Inst[3]];
						else
							local FlatIdent_66193 = 0;
							local A;
							while true do
								if (0 == FlatIdent_66193) then
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_66193 = 1;
								end
								if (FlatIdent_66193 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									FlatIdent_66193 = 7;
								end
								if (FlatIdent_66193 == 2) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_66193 = 3;
								end
								if (FlatIdent_66193 == 5) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_66193 = 6;
								end
								if (FlatIdent_66193 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									break;
								end
								if (FlatIdent_66193 == 1) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_66193 = 2;
								end
								if (FlatIdent_66193 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_66193 = 5;
								end
								if (3 == FlatIdent_66193) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_66193 = 4;
								end
							end
						end
					elseif (Enum <= 52) then
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
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
					elseif (Enum > 53) then
						local FlatIdent_3A655 = 0;
						local A;
						while true do
							if (4 == FlatIdent_3A655) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_3A655 = 5;
							end
							if (7 == FlatIdent_3A655) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								break;
							end
							if (FlatIdent_3A655 == 0) then
								A = nil;
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								FlatIdent_3A655 = 1;
							end
							if (FlatIdent_3A655 == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_3A655 = 2;
							end
							if (6 == FlatIdent_3A655) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_3A655 = 7;
							end
							if (FlatIdent_3A655 == 2) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_3A655 = 3;
							end
							if (FlatIdent_3A655 == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_3A655 = 4;
							end
							if (FlatIdent_3A655 == 5) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_3A655 = 6;
							end
						end
					else
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
					end
				elseif (Enum <= 63) then
					if (Enum <= 58) then
						if (Enum <= 56) then
							if (Enum == 55) then
								if (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
							end
						elseif (Enum == 57) then
							local FlatIdent_5AB84 = 0;
							local A;
							local Results;
							local Edx;
							while true do
								if (FlatIdent_5AB84 == 1) then
									Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									break;
								end
								if (FlatIdent_5AB84 == 0) then
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
									FlatIdent_5AB84 = 1;
								end
							end
						else
							Stk[Inst[2]] = Upvalues[Inst[3]];
						end
					elseif (Enum <= 60) then
						if (Enum > 59) then
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
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						else
							local FlatIdent_2E3FF = 0;
							local A;
							while true do
								if (FlatIdent_2E3FF == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									break;
								end
								if (FlatIdent_2E3FF == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_2E3FF = 6;
								end
								if (0 == FlatIdent_2E3FF) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_2E3FF = 1;
								end
								if (FlatIdent_2E3FF == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_2E3FF = 5;
								end
								if (FlatIdent_2E3FF == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_2E3FF = 4;
								end
								if (FlatIdent_2E3FF == 8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_2E3FF = 9;
								end
								if (FlatIdent_2E3FF == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_2E3FF = 2;
								end
								if (FlatIdent_2E3FF == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_2E3FF = 3;
								end
								if (FlatIdent_2E3FF == 6) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_2E3FF = 7;
								end
								if (7 == FlatIdent_2E3FF) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_2E3FF = 8;
								end
							end
						end
					elseif (Enum <= 61) then
						local FlatIdent_5077 = 0;
						local A;
						while true do
							if (FlatIdent_5077 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_5077 = 3;
							end
							if (3 == FlatIdent_5077) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_5077 = 4;
							end
							if (FlatIdent_5077 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_5077 = 2;
							end
							if (FlatIdent_5077 == 0) then
								A = nil;
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_5077 = 1;
							end
							if (FlatIdent_5077 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5077 = 5;
							end
							if (FlatIdent_5077 == 5) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								break;
							end
						end
					elseif (Enum > 62) then
						local FlatIdent_A446 = 0;
						local A;
						while true do
							if (FlatIdent_A446 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								FlatIdent_A446 = 3;
							end
							if (FlatIdent_A446 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_A446 == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_A446 = 4;
							end
							if (FlatIdent_A446 == 1) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								FlatIdent_A446 = 2;
							end
							if (0 == FlatIdent_A446) then
								A = nil;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_A446 = 1;
							end
						end
					else
						local A = Inst[2];
						local B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
					end
				elseif (Enum <= 68) then
					if (Enum <= 65) then
						if (Enum == 64) then
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
							local FlatIdent_56394 = 0;
							local A;
							local Cls;
							while true do
								if (FlatIdent_56394 == 0) then
									A = Inst[2];
									Cls = {};
									FlatIdent_56394 = 1;
								end
								if (FlatIdent_56394 == 1) then
									for Idx = 1, #Lupvals do
										local List = Lupvals[Idx];
										for Idz = 0, #List do
											local Upv = List[Idz];
											local NStk = Upv[1];
											local DIP = Upv[2];
											if ((NStk == Stk) and (DIP >= A)) then
												local FlatIdent_5BCFC = 0;
												while true do
													if (0 == FlatIdent_5BCFC) then
														Cls[DIP] = NStk[DIP];
														Upv[1] = Cls;
														break;
													end
												end
											end
										end
									end
									break;
								end
							end
						end
					elseif (Enum <= 66) then
						local FlatIdent_2F298 = 0;
						local A;
						while true do
							if (FlatIdent_2F298 == 0) then
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								break;
							end
						end
					elseif (Enum > 67) then
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
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					else
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
					end
				elseif (Enum <= 70) then
					if (Enum > 69) then
						Stk[Inst[2]] = Inst[3];
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
						Stk[Inst[2]] = Inst[3];
					end
				elseif (Enum <= 71) then
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
					Stk[Inst[2]] = Inst[3];
				elseif (Enum > 72) then
					Stk[Inst[2]][Inst[3]] = Inst[4];
				elseif not Stk[Inst[2]] then
					VIP = VIP + 1;
				else
					VIP = Inst[3];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4D3O00028O00026O00204003083O00496E7374616E63652O033O006E657703083O005549436F726E6572030C3O00436F726E657252616469757303043O005544696D026O00144003063O00506172656E74030A3O005465787442752O746F6E03043O0053697A6503053O005544696D32026O66D63F026O33C33F03083O00506F736974696F6E029A5O99B93F026O66E63F026O002240027O0040026O002440026O004440026O00F03F026O0044C003163O004261636B67726F756E645472616E73706172656E6379026O00084003093O005363722O656E47756903043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030C3O0057616974466F724368696C6403093O00506C6179657247756903053O004672616D65026O007940025O00C07240026O00E03F030B3O00416E63686F72506F696E7403073O00566563746F7232026O001840030A3O0054657874436F6C6F723303063O00436F6C6F723303073O0066726F6D524742025O00C0624003073O0054657874426F78029A5O99E93F029A5O99C93F029A5O99D93F026O001C40026O00284003113O004D6F75736542752O746F6E31436C69636B03073O00436F2O6E656374026O002A40026O001040026O003E40029A5O99A93F03043O0054657874030A3O004B65792053797374656D03083O005465787453697A65026O003240025O00E06F4003103O004261636B67726F756E64436F6C6F7233026O002E40030F3O00426F7264657253697A65506978656C03063O004163746976652O0103093O004472612O6761626C65026O003940030F3O00506C616365686F6C64657254657874030C3O00456E746572204B65793O2E034O0003093O00546578744C6162656C031E3O00456E746572204B657920546F20412O63652O73205468652053637269707403073O00476574204B657903023O00C397030A3O00546578745363616C6564026O00264003093O00436865636B204B6579029A5O99E13F0079012O0012463O00014O00430001000E3O0026373O0026000100020004113O00260001001205000F00033O002017000F000F000400122O001000056O000F000200024O0008000F3O00122O000F00073O00202O000F000F000400122O001000013O00122O001100086O000F0011000200102O00080006000F00101900080009000700122C000F00033O00202O000F000F000400122O0010000A6O000F000200024O0009000F3O00122O000F000C3O00202O000F000F000400122O0010000D3O00122O001100013O00122O0012000E3O001246001300014O0036000F0013000200102O0009000B000F00122O000F000C3O00202O000F000F000400122O001000103O00122O001100013O00122O001200113O00122O001300016O000F0013000200102O0009000F000F0012463O00123O0026373O0046000100130004113O00460001001205000F00073O002027000F000F000400122O001000013O00122O001100146O000F0011000200102O00030006000F00102O00030009000200122O000F00033O00202O000F000F000400122O0010000A6O000F000200022O00330004000F3O00123B000F000C3O00202O000F000F000400122O001000013O00122O001100153O00122O001200013O00122O001300156O000F0013000200102O0004000B000F00122O000F000C3O00202O000F000F0004001246001000163O001201001100173O00122O001200013O00122O001300016O000F0013000200102O0004000F000F00302O00040018001600124O00193O0026373O0070000100010004113O00700001001205000F00033O002012000F000F000400122O0010001A6O000F000200024O0001000F3O00122O000F001B3O00202O000F000F001C00202O000F000F001D00202O000F000F001E00122O0011001F6O000F0011000200101900010009000F00122C000F00033O00202O000F000F000400122O001000206O000F000200024O0002000F3O00122O000F000C3O00202O000F000F000400122O001000013O00122O001100213O00122O001200013O001246001300224O0036000F0013000200102O0002000B000F00122O000F000C3O00202O000F000F000400122O001000233O00122O001100013O00122O001200233O00122O001300016O000F0013000200102O0002000F000F001205000F00253O00200D000F000F000400122O001000233O00122O001100236O000F0011000200102O00020024000F00124O00163O0026373O0091000100260004113O00910001001205000F00283O002003000F000F002900122O0010002A3O00122O0011002A3O00122O0012002A6O000F0012000200102O00060027000F00302O00060018001600102O00060009000200122O000F00033O00202O000F000F00040012460010002B4O0040000F000200024O0007000F3O00122O000F000C3O00202O000F000F000400122O0010002C3O00122O001100013O00122O0012002D3O00122O001300016O000F0013000200102O0007000B000F001205000F000C3O00201C000F000F000400122O001000103O00122O001100013O00122O0012002E3O00122O001300016O000F0013000200102O0007000F000F00124O002F3O0026373O009E000100300004113O009E0001001019000C0009000B00202F000F0009003100203E000F000F003200021000116O0042000F001100012O0043000D000D3O000210000D00014O0043000E000E3O000607000E0002000100012O00333O000D3O0012463O00333O0026373O00BB000100340004113O00BB0001001205000F000C3O00201A000F000F000400122O001000163O00122O001100013O00122O001200013O00122O001300356O000F0013000200102O0005000B000F00122O000F000C3O00202O000F000F000400122O001000013O001246001100013O001213001200363O00122O001300016O000F0013000200102O0005000F000F00302O00050037003800302O00050039003A00122O000F00283O00202O000F000F002900122O0010003B3O00122O0011003B3O0012460012003B4O0009000F0012000200101900050027000F0030490005001800160012463O00083O0026373O00CE000100160004113O00CE0001001205000F00283O00202E000F000F002900122O0010003D3O00122O0011003D3O00122O0012003D6O000F0012000200102O0002003C000F00302O0002003E000100302O0002003F004000302O00020041004000102O000200090001001205000F00033O00202B000F000F000400122O001000056O000F000200024O0003000F3O00124O00133O0026373O00E30001002F0004113O00E30001001205000F00283O002023000F000F002900122O001000423O00122O001100423O00122O001200426O000F0012000200102O0007003C000F00302O00070043004400302O00070037004500302O00070039003A00122O000F00283O00202F000F000F00290012470010003B3O00122O0011003B3O00122O0012003B6O000F0012000200102O00070027000F00102O00070009000200124O00023O0026373O00FE000100080004113O00FE000100101900050009000200122C000F00033O00202O000F000F000400122O001000466O000F000200024O0006000F3O00122O000F000C3O00202O000F000F000400122O001000163O00122O001100013O00122O001200013O001246001300354O0036000F0013000200102O0006000B000F00122O000F000C3O00202O000F000F000400122O001000013O00122O001100013O00122O0012002D3O00122O001300016O000F0013000200102O0006000F000F0030490006003700470030490006003900330012463O00263O000E06001200172O013O0004113O00172O01001205000F00283O00203C000F000F002900122O001000423O00122O001100423O00122O001200426O000F0012000200102O0009003C000F00302O00090037004800302O00090039003A00122O000F00283O00202O000F000F00290012460010002A3O0012320011002A3O00122O0012002A6O000F0012000200102O00090027000F00102O00090009000200122O000F00033O00202O000F000F000400122O001000056O000F000200024O000A000F3O0012463O00143O000E060019002E2O013O0004113O002E2O010030490004003700490030440004004A004000122O000F00283O00202O000F000F002900122O0010002A3O00122O0011002A3O00122O0012002A6O000F0012000200102O00040027000F00102O00040009000200202O000F0004003100203E000F000F003200060700110003000100012O00333O00014O0045000F0011000100122O000F00033O00202O000F000F000400122O001000466O000F000200024O0005000F3O00124O00343O0026373O00462O01004B0004113O00462O01003049000B0037004C003024000B0039003A00122O000F00283O00202O000F000F002900122O0010002A3O00122O0011002A3O00122O0012002A6O000F0012000200102O000B0027000F00102O000B0009000200122O000F00033O002017000F000F000400122O001000056O000F000200024O000C000F3O00122O000F00073O00202O000F000F000400122O001000013O00122O001100086O000F0011000200102O000C0006000F0012463O00303O0026373O00502O0100330004113O00502O0100202F000F000B003100203E000F000F003200060700110004000100032O00333O00074O00333O000E4O00333O00014O0042000F001100010004113O00772O010026373O0002000100140004113O00020001001205000F00073O002027000F000F000400122O001000013O00122O001100086O000F0011000200102O000A0006000F00102O000A0009000900122O000F00033O00202O000F000F000400122O0010000A6O000F000200022O0033000B000F3O00123B000F000C3O00202O000F000F000400122O0010000D3O00122O001100013O00122O0012000E3O00122O001300016O000F0013000200102O000B000B000F00122O000F000C3O00202O000F000F00040012460010004D3O001218001100013O00122O001200113O00122O001300016O000F0013000200102O000B000F000F00122O000F00283O00202O000F000F002900122O001000423O00122O001100423O00122O001200424O0009000F00120002001019000B003C000F0012463O004B3O0004113O000200012O00418O000E3O00013O00053O00023O00030C3O00736574636C6970626F617264031F3O004B4559204953204F4E4C5920474956454E20544F2057484954454C4953542E00043O0012053O00013O001246000100024O001D3O000200012O000E3O00017O000C3O00028O00027O0040026O00F03F03063O00676D617463682O033O0025532B03053O007461626C6503063O00696E7365727403493O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5468656F62667573696361746F726775792F4B4559532F6D61696E2F5343524950542E7478743F03043O007469636B03053O007063612O6C03043O007761726E03153O004661696C656420746F206665746368206B6579733A00463O0012463O00014O0043000100053O0026373O003B000100020004113O003B00012O0043000500053O001246000600013O00263700060017000100030004113O0017000100263700010005000100020004113O0005000100203E000700040004001246000900054O00390007000900090004113O00130001001205000B00063O00202F000B000B00072O0033000C00054O0033000D000A4O0042000B000D00010006020007000E000100010004113O000E00012O0022000500023O0004113O0005000100263700060006000100010004113O0006000100263700010026000100010004113O00260001001246000700083O001205000800094O00210008000100022O00290002000700080012050007000A3O00060700083O000100012O00333O00024O000A0007000200082O0033000400084O0033000300073O001246000100033O00263700010037000100030004113O0037000100064800030034000100010004113O00340001001246000700013O0026370007002B000100010004113O002B00010012050008000B3O00121E0009000C6O000A00046O0008000A00014O00088O000800023O00044O002B00012O003100076O0033000500073O001246000100023O001246000600033O0004113O000600010004113O000500010004113O004500010026373O003F000100030004113O003F00012O0043000300043O0012463O00023O0026373O0002000100010004113O00020001001246000100014O0043000200023O0012463O00033O0004113O000200012O000E3O00013O00013O00023O0003043O0067616D6503073O00482O747047657400063O0012353O00013O00206O00024O00029O0000029O008O00017O00033O00028O0003053O007061697273026O00F03F011D3O001246000100014O0043000200023O001246000300013O000E0600010003000100030004113O0003000100263700010015000100010004113O001500012O003A00046O00150004000100024O000200043O00122O000400026O000500026O00040002000600044O0012000100060C3O0012000100080004113O001200012O0030000900014O0022000900023O0006020004000E000100020004113O000E0001001246000100033O00263700010002000100030004113O000200012O003000046O0022000400023O0004113O000200010004113O000300010004113O000200012O000E3O00017O00013O0003073O0044657374726F7900044O003A7O00203E5O00012O001D3O000200012O000E3O00017O000D3O00028O0003043O0054657874027O0040032O052O009O203O202O2D2047756920746F204C75610A9O203O202O2D2056657273696F6E3A20332E322O0A9O203O202O2D20496E7374616E6365733A2O0A9O203O206C6F63616C205363722O656E477569203D20496E7374616E63652E6E657728225363722O656E47756922290A9O203O206C6F63616C204672616D65203D20496E7374616E63652E6E657728224672616D6522290A9O203O206C6F63616C20546578744C6162656C203D20496E7374616E63652E6E65772822546578744C6162656C22292O0A9O203O202O2D2050726F706572746965733A2O0A9O203O205363722O656E4775692E506172656E74203D2067616D652E506C61796572732E4C6F63616C506C617965723A57616974466F724368696C642822506C6179657247756922290A9O203O205363722O656E4775692E5A496E6465784265686176696F72203D20456E756D2E5A496E6465784265686176696F722E5369626C696E672O0A9O203O204672616D652E506172656E74203D205363722O656E4775690A9O203O204672616D652E4261636B67726F756E64436F6C6F7233203D20436F6C6F72332E66726F6D52474228322O352C20322O352C20322O35290A9O203O204672616D652E426F72646572436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A9O203O204672616D652E426F7264657253697A65506978656C203D20300A9O203O204672616D652E506F736974696F6E203D205544696D322E6E657728302C20302C202D302E2O303233383437303132382C2030290A9O203O204672616D652E53697A65203D205544696D322E6E657728312C20302C20312C2030292O0A9O203O20546578744C6162656C2E506172656E74203D205363722O656E4775690A9O203O20546578744C6162656C2E4261636B67726F756E64436F6C6F7233203D20436F6C6F72332E66726F6D52474228322O352C20322O352C20322O35290A9O203O20546578744C6162656C2E426F72646572436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A9O203O20546578744C6162656C2E426F7264657253697A65506978656C203D20300A9O203O20546578744C6162656C2E506F736974696F6E203D205544696D322E6E657728302E3334374O3230392C20302C20302E33353239342O312O352C2030290A9O203O20546578744C6162656C2E53697A65203D205544696D322E6E657728302C20322O302C20302C203530290A9O203O20546578744C6162656C2E466F6E74203D20456E756D2E466F6E742E536F7572636553616E730A9O203O20546578744C6162656C2E54657874203D2022554E4C4F434B4544205941594159412O59415941220A9O203O20546578744C6162656C2E54657874436F6C6F7233203D20436F6C6F72332E66726F6D52474228302C20302C2030290A9O203O20546578744C6162656C2E5465787453697A65203D2031342E3O300A8O20030A3O006C6F6164737472696E67026O00F03F030F3O00506C616365686F6C64657254657874030C3O00436F2O72656374204B657921034O0003043O007761697403073O0044657374726F79030C3O00456E746572204B65793O2E03173O00496E76616C6964206B65792E2054727920616761696E2E00593O0012463O00014O0043000100013O0026373O0002000100010004113O000200012O003A00025O0020040001000200024O000200016O000300016O00020002000200062O0002003700013O0004113O00370001001246000200014O0043000300033O00263700020015000100030004113O00150001001246000300043O00122A000400056O000500036O0004000200024O00040001000100044O0058000100263700020024000100010004113O00240001001246000400013O0026370004001C000100060004113O001C0001001246000200063O0004113O0024000100263700040018000100010004113O001800012O003A00055O00301F0005000700084O00055O00302O00050002000900122O000400063O00044O001800010026370002000D000100060004113O000D0001001246000400013O00263700040030000100010004113O003000010012050005000A3O00121B000600066O0005000200014O000500023O00202O00050005000B4O00050002000100122O000400063O00263700040027000100060004113O00270001001246000200033O0004113O000D00010004113O002700010004113O000D00010004113O00580001001246000200014O0043000300033O00263700020039000100010004113O00390001001246000300013O000E0600060044000100030004113O004400010012050004000A3O00123F000500066O0004000200014O00045O00302O00040007000C00044O005800010026370003003C000100010004113O003C0001001246000400013O0026370004004B000100060004113O004B0001001246000300063O0004113O003C000100263700040047000100010004113O004700012O003A00055O00301F00050007000D4O00055O00302O00050002000900122O000400063O00044O004700010004113O003C00010004113O005800010004113O003900010004113O005800010004113O000200012O000E3O00017O00", GetFEnv(), ...);
