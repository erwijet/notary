import { z } from "zod";
import { authorizationResultSchema, inspectionResultSchema } from "./schemas";
import { createZodHttpTransport } from "./transport";

type InspectionResult = z.infer<typeof inspectionResultSchema>;
type AuthorizeResult = z.infer<typeof authorizationResultSchema>;

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
     * The default callback url that the user will be navigated to upon a successful completion of the authorization flow, with a `?token=` URL parameter.
     * This may be overridden at a per-flow basis by passing in an override when calling {@link Notary.authorize authorize( ... )}.
     */
    callback: string;
};

export type Notary = {
    /**
     * Issues a new unique, temporary, once time use URL which the user can navigate to to log in with the specified provider.
     */
    authorize: (opts: { via: Provider; callback?: string }) => Promise<AuthorizeResult>;
    /**
     * Validates the given notary token and, if valid, returns the user data associated with it.
     */
    inspect: (token: Token) => Promise<InspectionResult>;
};

/**
 * Creates a notary client instance which can be used to interact with the specified notary server
 */
export function createNotary({ client, url, key, callback }: Options): Notary {
    const transport = createZodHttpTransport(url);

    return {
        authorize({ callback: callbackOverride, via }) {
            return transport.get(
                `/authorize/${client}?via=${via}&key=${key}&callback=${callbackOverride ?? callback}`,
                authorizationResultSchema,
            );
        },
        inspect(token) {
            return transport.get(`/inspect/${token}`, inspectionResultSchema);
        },
    };
}
