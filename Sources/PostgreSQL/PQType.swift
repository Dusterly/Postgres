#if os(macOS)
import LibpqMac
#else
import LibpqLinux
#endif

// https://github.com/LuaDist/libpq/blob/master/src/interfaces/ecpg/ecpglib/pg_type.h

public enum PQType: Oid {
	case byteArray = 17
	case int8 = 20
	case int2 = 21
	case int4 = 23
	case text = 25
	case float4 = 700
	case float8 = 701
}
