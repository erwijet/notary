import { z } from "zod";
import { authenticationResultSchema, inspectionResultSchema, renewResultSchema } from "./schemas";
import { createZodHttpTransport } from "./transport";

type InspectionResult = z.infer<typeof inspectionResultSchema>;
type AuthenticateResult = z.infer<typeof authenticationResultSchema>;
type RenewResult = z.infer<typeof renewResultSchema>;

export type Token = string;
export type Provider = "google";

export type Options = {
    /**
     * The URL of the hosted notary server, for example `https://notary.example.com`.
     */
    url: string;
    /**
     * The client name, as specified in the notary portal.
     */
    client: string;
    /**
     * The associated key for the client specified.
     */
    key: string;
    /**
     * The default callback url that the user will be navigated to upon a successful completion of the authentication flow, with a `?token=` URL parameter.
     * This may be overridden at a per-flow basis by passing in an override when calling {@link Notary.authenticate authenticate( ... )}.
     */
    callback: string;
};

export type Notary = {
    /**
     * Issues a new unique, temporary, once time use URL which the user can navigate to to log in with the specified provider.
     */
    authenticate: (opts: { via: Provider; callback?: string }) => Promise<AuthenticateResult>;
    /**
     * Validates the given notary token and, if valid, returns the user data associated with it.
     */
    inspect: (token: Token) => Promise<InspectionResult>;
    /**
     * Reissues the given token with a fresh expiration time
     */
    renew: (token: Token) => Promise<RenewResult>;
};

/**
 * Creates a notary client instance which can be used to interact with the specified notary server
 */
export function createNotary({ client, url, key, callback }: Options): Notary {
    const transport = createZodHttpTransport(url);

    return {
        authenticate({ callback: callbackOverride, via }) {
            return transport.get(
                `/authorize/${client}?via=${via}&key=${key}&callback=${callbackOverride ?? callback}`,
                authenticationResultSchema,
            );
        },
        inspect(token) {
            return transport.get(`/inspect/${token}`, inspectionResultSchema);
        },
        renew(token) {
            return transport.get(`/renew/${token}`, renewResultSchema);
        },
    };
}
