{-# LANGUAGE ScopedTypeVariables, PackageImports #-}

-- | Conversions between Repa Arrays and ByteStrings.
module Data.Array.Repa.ByteString
	( toByteString
	, fromByteString
	, copyFromPtrWord8
	, copyToPtrWord8)
where
import Data.Word
import Data.Array.Repa
import Foreign.Marshal.Alloc
import Foreign.Ptr
import Foreign.Storable
import System.IO.Unsafe
import qualified Data.Vector.Unboxed	as V
import qualified Data.ByteString	as BS
import Data.ByteString			(ByteString)


-- | Convert an `Array` to a (strict) `ByteString`.
toByteString 
	:: Shape sh
	=> Array sh Word8
	-> ByteString

toByteString arr
 = unsafePerformIO
 $ allocaBytes (size $ extent arr)	$ \(bufDest :: Ptr Word8) ->
   let 	vec	= toVector arr
	len	= size $ extent arr

	copy offset
	 | offset >= len
	 = return ()

	 | otherwise
	 = do	pokeByteOff bufDest offset (vec `V.unsafeIndex` offset)
		copy (offset + 1)

    in do
	copy 0
	BS.packCStringLen (castPtr bufDest, len)



-- | Copy a (strict) `ByteString` to a new `Array`.
--	The given array extent must match the length of the `ByteString`, else `error`.
fromByteString 
	:: Shape sh
	=> sh
	-> ByteString 
	-> Array sh Word8

-- TODO: Use an intermediate CString when we do this, to avoid
--	 the overhead from bounds checks in ByteString
fromByteString sh str
	| size sh /= BS.length str
	= error "Data.Array.Repa.fromByteString: given array size does not match length of string"
	
	| otherwise
	= fromFunction sh (\ix -> str `BS.index` toIndex sh ix)


-- Ptr utils ------------------------------------------------------------------
-- | Copy some data from somewhere into a new `Array`.
--   TODO: fake this somehow to avoid the copy. 
--         maybe we want to allocate the array and use that as the CGContext directly.
--         Avoid going via fromFunction in Data.Vector. Data.Vector might need some hacks.
copyFromPtrWord8 
	:: Shape sh
	=> sh
	-> Ptr Word8
	-> IO (Array sh Word8)
	
copyFromPtrWord8 sh ptr
 = do	return	$ fromFunction sh (\ix -> unsafePerformIO (peekElemOff ptr (toIndex sh ix)))


-- | Copy some data into a buffer
copyToPtrWord8 
	:: Shape sh
	=> Ptr Word8
	-> Array sh Word8
	-> IO ()
	
copyToPtrWord8 ptr arr
 = let	vec	= toVector arr
	len	= size $ extent arr
	
	copy offset
	 | offset >= len
	 = return ()
	
	 | otherwise
	 = do	pokeByteOff ptr offset (vec `V.unsafeIndex` offset)
		copy (offset + 1)

   in do
	copy 0
	return ()
	