package com.farmerassist.backend.exception;

/**
 * Thrown when the upstream data.gov.in Agmarknet API cannot be reached
 * or returns something we can't work with. Kept distinct from validation
 * errors so the global handler can map it to a 502 instead of a 400.
 */
public class MandiPriceFetchException extends RuntimeException {

    public MandiPriceFetchException(String message) {
        super(message);
    }

    public MandiPriceFetchException(String message, Throwable cause) {
        super(message, cause);
    }
}
