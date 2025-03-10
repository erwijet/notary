import {
  ActionIcon,
  Box,
  Button,
  Container,
  CopyButton,
  Divider,
  Fieldset,
  Group,
  Loader,
  Menu,
  Modal,
  Paper,
  Pill,
  Space,
  Stack,
  Table,
  TextInput,
  Title,
  Tooltip,
} from "@mantine/core";
import { z } from "zod";
import { useForm } from "@mantine/form";
import {
  IconBrandGoogle,
  IconBrandGoogleFilled,
  IconLogin,
  IconPasswordFingerprint,
  IconPlus,
  IconTrash,
  IconUserEdit,
  IconUserOff,
} from "@tabler/icons-react";
import { useEffect, useState } from "react";
import { Footer } from "src/Footer";
import { httpDelete, httpGet, httpPost, httpPut } from "src/http";
import { Client, clientSchema } from "src/schema";
import { maybe } from "@tsly/maybe";
import { modals } from "@mantine/modals";

function ClientForm(props: { activeId: string | null; onClose: () => void }) {
  const [isLoading, setIsLoading] = useState(!!props.activeId);
  const [isSaveLoading, setIsSaveLoading] = useState(false);

  const form = useForm<Client>({
    name: "client",
  });

  useEffect(() => {
    if (!props.activeId) return;

    setIsLoading(true);

    httpGet("/portal/clients/" + props.activeId)
      .then((res) => clientSchema.parse(res))
      .then((client) => form.setValues(client))
      .finally(() => setIsLoading(false));
  }, [props.activeId]);

  async function handleDone() {
    setIsSaveLoading(true);

    try {
      if (!!props.activeId)
        await httpPut("/portal/clients/" + props.activeId, form.values);
      else await httpPost("/portal/clients", form.values);

      props.onClose();
    } catch (resp: any) {
      const { status } = resp as Response;

      if (status == 409)
        alert(
          "Conflict! make sure 'name' and 'key' fields are both unique across all your clients"
        );
      else alert("Unexpected HTTP error: " + status);
    } finally {
      setIsSaveLoading(false);
    }
  }

  return isLoading ? (
    <Loader type="dots" />
  ) : (
    <Stack>
      <TextInput label="Client Name" {...form.getInputProps("name")} />
      <TextInput label="Key" {...form.getInputProps("key")} />

      <Fieldset legend="OAuth2 Client IDs">
        <TextInput
          label="Google"
          {...form.getInputProps("google_oauth_client_id")}
        />
      </Fieldset>

      <Group justify="flex-end">
        <Button
          loading={isSaveLoading}
          loaderProps={{ type: "dots" }}
          onClick={() => handleDone()}
        >
          {!!props.activeId ? "Save" : "Create"}
        </Button>
      </Group>
    </Stack>
  );
}

export function Portal() {
  const [activeId, setActiveId] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [data, setData] = useState<Client[]>([]);

  function editClient(id: number) {
    setActiveId(id.toString());
    setIsModalOpen(true);
  }

  function newClient() {
    setActiveId(null);
    setIsModalOpen(true);
  }

  function deleteClient(id: number) {
    if (!confirm("Are you sure you want delete this client?")) return;

    httpDelete("/portal/clients/" + id).then(() => loadData());
  }

  function launchGoogleOAuthFlow(client: Client) {
    httpGet(
      `/authorize/${client.name}?via=google&key=${
        client.key
      }&callback=${encodeURIComponent(window.location.origin)}`
    )
      .then((res) => z.object({ url: z.string() }).parse(res))
      .then(({ url }) => {
        window.location.href = url;
      });
  }

  function loadData() {
    setIsLoading(true);

    httpGet("/portal/clients")
      .then((res) => z.object({ clients: clientSchema.array() }).parse(res))
      .then((data: any) => setData(data.clients))
      .finally(() => setIsLoading(false));
  }

  useEffect(() => {
    if (!isModalOpen) {
      setActiveId(null);
      loadData();
    }
  }, [isModalOpen]);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    const q = new URLSearchParams(window.location.search);
    if (!!q.get("token"))
      modals.open({
        centered: true,
        size: "xl",
        title: <Title order={5}>Token</Title>,
        onClose() {
          window.location.search = new URLSearchParams().toString();
        },
        children: (
          <Stack>
            <Group mt="xs">
              <TextInput disabled flex={1} value={q.get("token")!} />
              <CopyButton value={q.get("token")!}>
                {({ copy, copied }) => (
                  <Button variant="default" onClick={copy}>
                    {copied ? "Copied!" : "Copy"}
                  </Button>
                )}
              </CopyButton>
            </Group>
          </Stack>
        ),
      });
  }, []);

  return (
    <div>
      <Modal
        opened={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        centered
        title={
          <Title order={4}>{`${!!activeId ? "Edit" : "Create"} Client`}</Title>
        }
      >
        <ClientForm activeId={activeId} onClose={() => setIsModalOpen(false)} />
      </Modal>

      <Container p="md" h="100vh">
        <Group w="100%" justify="space-between">
          <Title order={2}>Notary Portal</Title>
          <Button
            variant="subtle"
            size="compact-sm"
            leftSection={<IconPlus size={16} />}
            onClick={() => newClient()}
          >
            New Client
          </Button>
        </Group>

        <Space h="md" />

        <Divider />

        <Space h="xl" />

        <Paper withBorder>
          <Table horizontalSpacing={"md"} verticalSpacing={"sm"}>
            {isLoading ? (
              <Group w="100%" justify="center" my="xl" gap="xs">
                <Loader type="oval" size={"xs"} /> Loading...
              </Group>
            ) : (
              <>
                <Table.Thead>
                  <Table.Tr>
                    <Table.Th>Client Name</Table.Th>
                    <Table.Th>Key</Table.Th>
                    <Table.Th>Google ClientID</Table.Th>
                    <Table.Th align="left"></Table.Th>
                  </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                  {data.map((each) => (
                    <Table.Tr>
                      <Table.Td>{each.name}</Table.Td>
                      <Table.Td>
                        {each.key
                          .split("")
                          .map((_) => "•")
                          .join("")}
                      </Table.Td>
                      <Table.Td>
                        {maybe(each.google_oauth_client_id)?.take(
                          (it) =>
                            it
                              .slice(0, -5)
                              .split("")
                              .map(() => "•")
                              .join("") + it.slice(-5)
                        ) ?? <Pill>None</Pill>}
                      </Table.Td>
                      <Table.Td align="right">
                        <ActionIcon
                          variant="subtle"
                          onClick={() => editClient(each.id)}
                        >
                          <IconUserEdit size={18} />
                        </ActionIcon>
                        <Menu>
                          <Menu.Target>
                            <Tooltip label="Launch Login">
                              <ActionIcon variant="subtle">
                                <IconPasswordFingerprint size={18} />
                              </ActionIcon>
                            </Tooltip>
                          </Menu.Target>
                          <Menu.Dropdown>
                            <Menu.Item
                              leftSection={<IconBrandGoogleFilled size={16} />}
                              onClick={() => launchGoogleOAuthFlow(each)}
                            >
                              Launch Google OAuth Flow
                            </Menu.Item>
                          </Menu.Dropdown>
                        </Menu>
                        <ActionIcon
                          variant="subtle"
                          color="red"
                          onClick={() => deleteClient(each.id)}
                        >
                          <IconTrash size={18} />
                        </ActionIcon>
                      </Table.Td>
                    </Table.Tr>
                  ))}
                </Table.Tbody>
              </>
            )}
          </Table>
        </Paper>
      </Container>

      <Footer />
    </div>
  );
}
