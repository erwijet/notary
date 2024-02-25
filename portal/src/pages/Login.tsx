import {
  Box,
  Button,
  Group,
  Stack,
  TextInput,
  Title,
  useMantineTheme,
} from "@mantine/core";
import { useState } from "react";
import { Footer } from "src/Footer";
import { usePortalStore } from "src/store";
import { z } from "zod";

const loginTokenSchema = z.object({
  token: z.string(),
});

export function Login() {
  const [passkey, setPasskey] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const { setToken } = usePortalStore();

  function login() {
    setIsLoading(true);

    return fetch("/portal/auth", {
      method: "post",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ passkey }),
    })
      .then((res) => res.json())
      .then((res) => loginTokenSchema.parse(res))
      .then((res) => setToken(res.token));
  }

  return (
    <Box
      display={"flex"}
      w="100vw"
      h="100vh"
      style={{ alignItems: "center", justifyContent: "center" }}
    >
      <Stack flex={"1 1 0"} align="center">
        <Stack>
          <Title order={3}>Notary Portal</Title>
          <Group
            align="flex-end"
            component={"form"}
            onSubmit={(e) => {
              e.preventDefault();
              login()
                .catch(() => setError("Invalid passkey. Please try again."))
                .finally(() => setIsLoading(false));
            }}
          >
            <TextInput
              autoFocus
              type="password"
              value={passkey}
              onChange={(e) => setPasskey(e.target.value)}
              label="Passkey"
              error={error}
              inputContainer={(children) => (
                <Group align="flex-start">
                  {children}
                  <Button
                    type="submit"
                    loading={isLoading}
                    loaderProps={{ type: "dots" }}
                  >
                    Continue
                  </Button>
                </Group>
              )}
            />
          </Group>
        </Stack>
        <Footer />
      </Stack>
      <Stack flex={"1 1 0"} bg={"indigo"} h="100%" />
    </Box>
  );
}
