# Plasma encrypted files.
# Their structure is very simple and identical across all games,
# with the only difference being the magic number.

0 string whatdoyousee Plasma XTEA-encrypted data, %s signature (Uru)
>12 use plasma_encrypted

0 string BriceIsSmart Plasma XTEA-encrypted data, %s signature (Uru)
>12 use plasma_encrypted

0 string notthedroids Plasma droid-encrypted data, %s signature (MOUL)
>12 use plasma_encrypted

0 lelong 0x0D874288 Plasma AES-encrypted data, %#x signature (Myst V)
>4 use plasma_encrypted

0 name plasma_encrypted
>0 lelong x \b, %u bytes

# Plasma PRP files, in their variations from different games and versions.
# PRP files do not have a magic number, so these patterns are not that reliable and often incorrectly match random binary files.
# The PRP format is also complex and obfuscated enough that it is difficult to extract much useful information from it.

# This "universal" variant seems to be internal to libHSPlasma and not used by any of the games.
# TODO This check is very weak!
0 leshort -1 Plasma PRP data, version %d (universal)

# All other known PRP format versions, according to libHSPlasma.
# Versions <= 5 store the PRP version in the first 4 bytes.
0 lelong 2
>0 use plasma_prp_nonlive_check
0 lelong 3
>0 use plasma_prp_nonlive_check
0 lelong 4
>0 use plasma_prp_nonlive_check
0 lelong 5
>0 use plasma_prp_nonlive_check
# Versions >= 6 store the PRP version in the first 2 bytes.
# The next 2 bytes store the number of entries in the "type map".
# Not sure what the actual practical limit of the type map count is,
# but libHSPlasma ResManager/pdUnifiedTypeMap.h defines TYPESPACE_MAX as 0x500,
# so that should be a safe maximum.
0 leshort 6
# A type map count of zero for version 6 indicates a MOUL PRP,
# which uses a different location encoding (see below) than other version 6 PRPs,
# which requires us to perform a heuristic check below slightly differently.
>2 uleshort 0
>>0 use plasma_prp_live_check
>2 uleshort <0x501
>>0 use plasma_prp_nonlive_check
0 leshort 9
>2 uleshort <0x501
>>0 use plasma_prp_nonlive_check

# Bytes 4 through 8 store the "location" field.
# The high 3 bytes (or high 2 bytes for MOUL) of the location field store the sequence prefix,
# the low byte (or low 2 bytes for MOUL) store the page number.
# (The exact encoding of these fields is a bit complex,
# but for our purposes it is close enough to a regular packed integer.)
# Low positive sequence prefixes (< 100) are used by Cyan ages,
# higher positive ones (the entire possible range basically) are used by fan ages.
# There are only very few negative sequence prefixes (-6 through -1),
# which (due to the weird encoding) means that in practice
# all negative sequence prefixes have all bits in the high 2 bytes (or high 1 byte for MOUL) set,
# and the lowest byte is <= 6.
# We use this as a heuristic to exclude some false positives. 

0 name plasma_prp_nonlive_check
>4 ulelong ^0x80000000
>>0 use plasma_prp
>4 ulelong &0xffff0000
>>5 ubyte <7
>>>0 use plasma_prp

0 name plasma_prp_live_check
>4 ulelong ^0x80000000
>>0 use plasma_prp
>4 ulelong &0xff000000
>>6 ubyte <7
>>>0 use plasma_prp

# If we got here, we're reasonably sure that this is actually a PRP.
# This is the part that actually outputs something.
# The PRP-version-to-game mappings come mostly from libHSPlasma PRP/plPageInfo.cpp.
0 name plasma_prp
>0 leshort x Plasma PRP data, version %d
>>0 lelong 2 (Plasma 2.0.56?)
>>>4 use plasma_prp_location
>>0 lelong 5 (Uru offline, Until Uru, etc.)
>>>4 use plasma_prp_location
>>0 leshort 6
>>>2 uleshort 0 (MOUL)
>>>>4 use plasma_prp_location
>>>2 uleshort !0 (Myst V, Crowthistle), type map with %d entries
>>>>4 use plasma_prp_location
>>0 leshort 9 (Cosmic Osmo's Hex Isle)
>>>2 uleshort 0
>>>>4 use plasma_prp_location
>>>2 uleshort !0 \b, type map with %d entries
>>>>4 use plasma_prp_location

# The encoding of the location field is very complex (see above),
# so we only recognize a couple of known special values,
# and otherwise just print out the raw value in hex.
0 name plasma_prp_location
# INVALID and VIRTUAL come from libHSPlasma PRP/KeyedObject/plLocation.cpp.
# Not sure if these have any meaning outside of libHSPlasma or can even appear in PRPs on disk.
>0 ulelong 0xffffffff \b, location state INVALID
>0 ulelong 0 \b, location state VIRTUAL
>0 ulelong x \b, location %#x

# Output format of libHSPlasma's PrpPack tool.
# Not sure if this format is used outside of libHSPlasma.
# But hey, it has a proper magic number at least!
0 string PRD\0 Plasma PRD data
>4 pstring/h x \b, age %s
>>&0 pstring/h x \b, page %s
>>>&0 uleshort x \b, Plasma version %u
>>>>&0 uleshort x \b.%u
>>>>>&0 ulelong x \b, page ID %#x
>>>>>>&0 uleshort x \b, location flags %#x

# .age and .fni are simple text files.
# These patterns recognize some common properties/commands from each of the two file types.
# These files are usually encrypted when distributed to players,
# which is why the description specifically points out that they are unencrypted.

0 regex/10/l (StartDateTime|DayLength|MaxCapacity|LingerTime|SequencePrefix|ReleaseVersion|Page) Plasma unencrypted .age configuration text
>0 regex/10/l Page=
>>&0 regex/1/l [^\r\n]+ \b, first page %s

0 regex/10/l Graphics\.Renderer\. Plasma unencrypted .fni configuration text

# Plasma fonts (.p2f).
# These do not have a magic number,
# but their first field is a fixed-width zero-padded 256-byte string storing the font name.
# Because most font names are significantly shorter than 256 bytes [citation needed],
# we assume that name byte 128 and after have to be zero,
# as a heuristic to avoid false positives.
# TODO This pattern is still quite weak - we should check that the font name is printable ASCII.
128 ulequad 0
>136 ulequad 0
>>144 ulequad 0
>>>152 ulequad 0
>>>>160 ulequad 0
>>>>>168 ulequad 0
>>>>>>176 ulequad 0
>>>>>>>184 ulequad 0
>>>>>>>>192 ulequad 0
>>>>>>>>>200 ulequad 0
>>>>>>>>>>208 ulequad 0
>>>>>>>>>>>216 ulequad 0
>>>>>>>>>>>>224 ulequad 0
>>>>>>>>>>>>>232 ulequad 0
>>>>>>>>>>>>>>240 ulequad 0
>>>>>>>>>>>>>>>248 ulequad 0
# Byte 256 is the font size.
# We assume that the font size is 48 or less
# (the largest fonts that come with Uru are size 32,
# so this should be safe enough).
>>>>>>>>>>>>>>>>256 ubyte <49
# Byte 256 are the font flags.
# Only the low two bits are used,
# so require all higher bits to be zero.
>>>>>>>>>>>>>>>>>257 ulelong ^0xfc
>>>>>>>>>>>>>>>>>>0 use plasma_p2f_font

# If we got here, we're reasonably sure that this is actually a P2F font.
# Output the font name and basic metadata.
0 name plasma_p2f_font
>0 string >\0 Plasma .p2f font data, name %s
>>256 ubyte x \b, size %u
>>>257 ulelong &0x1 \b, bold
>>>257 ulelong &0x2 \b, italic
