import {
    ActionIcon,
    Anchor,
    Divider,
    Group,
    Stack,
    Text
} from "@mantine/core";
import {
    IconBrandGithub,
    IconBrandLinkedin,
    IconBrandTwitter
} from "@tabler/icons-react";

export function Footer() {
  return (
    <Stack pos={"absolute"} bottom={0} p={"md"} w="100%">
      <Group justify="center">
        <Text>
          Made in Rochester, NY by{" "}
          <Anchor underline="hover" href="https://holewinski.dev">
            @erwijet
          </Anchor>
        </Text>
        <Divider orientation="vertical" />
        <Group gap={4}>
          <ActionIcon
            size={"sm"}
            variant="subtle"
            autoContrast
            component="a"
            href="https://github.com/erwijet/notary"
          >
            <IconBrandGithub />
          </ActionIcon>

          <ActionIcon
            size={"sm"}
            variant="subtle"
            autoContrast
            component="a"
            href="https://linkedin.com/in/tylerholewinski"
          >
            <IconBrandLinkedin />
          </ActionIcon>

          <ActionIcon
            size={"sm"}
            variant="subtle"
            autoContrast
            component="a"
            href="https://twitter.com/erwijet"
          >
            <IconBrandTwitter />
          </ActionIcon>
        </Group>
      </Group>
    </Stack>
  );
}
