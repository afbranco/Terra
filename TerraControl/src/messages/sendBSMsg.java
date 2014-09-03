/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'sendBSMsg'
 * message type.
 */
package messages;

public class sendBSMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 21;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 150;

    /** Create a new sendBSMsg of size 21. */
    public sendBSMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new sendBSMsg of the given data_length. */
    public sendBSMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new sendBSMsg with the given data_length
     * and base offset.
     */
    public sendBSMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new sendBSMsg using the given byte array
     * as backing store.
     */
    public sendBSMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new sendBSMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public sendBSMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new sendBSMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public sendBSMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new sendBSMsg embedded in the given message
     * at the given base offset.
     */
    public sendBSMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new sendBSMsg embedded in the given message
     * at the given base offset and length.
     */
    public sendBSMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <sendBSMsg> \n";
      try {
        s += "  [Sender=0x"+Long.toHexString(get_Sender())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [seq=0x"+Long.toHexString(get_seq())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [evtId=0x"+Long.toHexString(get_evtId())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [Data=";
        for (int i = 0; i < 16; i++) {
          s += "0x"+Long.toHexString(getElement_Data(i) & 0xff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: Sender
    //   Field type: int, unsigned
    //   Offset (bits): 0
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'Sender' is signed (false).
     */
    public static boolean isSigned_Sender() {
        return false;
    }

    /**
     * Return whether the field 'Sender' is an array (false).
     */
    public static boolean isArray_Sender() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'Sender'
     */
    public static int offset_Sender() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'Sender'
     */
    public static int offsetBits_Sender() {
        return 0;
    }

    /**
     * Return the value (as a int) of the field 'Sender'
     */
    public int get_Sender() {
        return (int)getUIntBEElement(offsetBits_Sender(), 16);
    }

    /**
     * Set the value of the field 'Sender'
     */
    public void set_Sender(int value) {
        setUIntBEElement(offsetBits_Sender(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'Sender'
     */
    public static int size_Sender() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'Sender'
     */
    public static int sizeBits_Sender() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: seq
    //   Field type: int, unsigned
    //   Offset (bits): 16
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'seq' is signed (false).
     */
    public static boolean isSigned_seq() {
        return false;
    }

    /**
     * Return whether the field 'seq' is an array (false).
     */
    public static boolean isArray_seq() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'seq'
     */
    public static int offset_seq() {
        return (16 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'seq'
     */
    public static int offsetBits_seq() {
        return 16;
    }

    /**
     * Return the value (as a int) of the field 'seq'
     */
    public int get_seq() {
        return (int)getUIntBEElement(offsetBits_seq(), 16);
    }

    /**
     * Set the value of the field 'seq'
     */
    public void set_seq(int value) {
        setUIntBEElement(offsetBits_seq(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'seq'
     */
    public static int size_seq() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'seq'
     */
    public static int sizeBits_seq() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: evtId
    //   Field type: short, unsigned
    //   Offset (bits): 32
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'evtId' is signed (false).
     */
    public static boolean isSigned_evtId() {
        return false;
    }

    /**
     * Return whether the field 'evtId' is an array (false).
     */
    public static boolean isArray_evtId() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'evtId'
     */
    public static int offset_evtId() {
        return (32 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'evtId'
     */
    public static int offsetBits_evtId() {
        return 32;
    }

    /**
     * Return the value (as a short) of the field 'evtId'
     */
    public short get_evtId() {
        return (short)getUIntBEElement(offsetBits_evtId(), 8);
    }

    /**
     * Set the value of the field 'evtId'
     */
    public void set_evtId(short value) {
        setUIntBEElement(offsetBits_evtId(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'evtId'
     */
    public static int size_evtId() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'evtId'
     */
    public static int sizeBits_evtId() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: Data
    //   Field type: short[], unsigned
    //   Offset (bits): 40
    //   Size of each element (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'Data' is signed (false).
     */
    public static boolean isSigned_Data() {
        return false;
    }

    /**
     * Return whether the field 'Data' is an array (true).
     */
    public static boolean isArray_Data() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'Data'
     */
    public static int offset_Data(int index1) {
        int offset = 40;
        if (index1 < 0 || index1 >= 16) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'Data'
     */
    public static int offsetBits_Data(int index1) {
        int offset = 40;
        if (index1 < 0 || index1 >= 16) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return offset;
    }

    /**
     * Return the entire array 'Data' as a short[]
     */
    public short[] get_Data() {
        short[] tmp = new short[16];
        for (int index0 = 0; index0 < numElements_Data(0); index0++) {
            tmp[index0] = getElement_Data(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'Data' from the given short[]
     */
    public void set_Data(short[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_Data(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a short) of the array 'Data'
     */
    public short getElement_Data(int index1) {
        return (short)getUIntBEElement(offsetBits_Data(index1), 8);
    }

    /**
     * Set an element of the array 'Data'
     */
    public void setElement_Data(int index1, short value) {
        setUIntBEElement(offsetBits_Data(index1), 8, value);
    }

    /**
     * Return the total size, in bytes, of the array 'Data'
     */
    public static int totalSize_Data() {
        return (128 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'Data'
     */
    public static int totalSizeBits_Data() {
        return 128;
    }

    /**
     * Return the size, in bytes, of each element of the array 'Data'
     */
    public static int elementSize_Data() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'Data'
     */
    public static int elementSizeBits_Data() {
        return 8;
    }

    /**
     * Return the number of dimensions in the array 'Data'
     */
    public static int numDimensions_Data() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'Data'
     */
    public static int numElements_Data() {
        return 16;
    }

    /**
     * Return the number of elements in the array 'Data'
     * for the given dimension.
     */
    public static int numElements_Data(int dimension) {
      int array_dims[] = { 16,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /**
     * Fill in the array 'Data' with a String
     */
    public void setString_Data(String s) { 
         int len = s.length();
         int i;
         for (i = 0; i < len; i++) {
             setElement_Data(i, (short)s.charAt(i));
         }
         setElement_Data(i, (short)0); //null terminate
    }

    /**
     * Read the array 'Data' as a String
     */
    public String getString_Data() { 
         char carr[] = new char[Math.min(net.tinyos.message.Message.MAX_CONVERTED_STRING_LENGTH,16)];
         int i;
         for (i = 0; i < carr.length; i++) {
             if ((char)getElement_Data(i) == (char)0) break;
             carr[i] = (char)getElement_Data(i);
         }
         return new String(carr,0,i);
    }

}