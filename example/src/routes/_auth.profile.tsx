import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_auth/profile")({
  component,
});

function component() {
  const { fullname, picture } = Route.useRouteContext();

  function logout() {
    localStorage.removeItem("dev.holewinski.notary.token");
    window.location.reload();
  }

  return (
    <div
      style={{
        display: "flex",
        justifyContent: "center",
        flexDirection: "column",
        height: "100vh",
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          width: "100vw",
        }}
      >
        <div
          style={{
            display: "flex",
            padding: "32px 64px",
            alignItems: "center",
            borderRadius: "4px",
            backgroundColor: "#f8f8f8",
            gap: "8px",
          }}
        >
          <img
            src={picture}
            style={{ width: "64px", height: "64px", borderRadius: "100%" }}
          />
          <p style={{ fontFamily: "sans-serif" }}>
            Welcome back, <br />
            <span style={{ fontWeight: "600" }}>{fullname}</span>
          </p>

          <div style={{ marginLeft: "8px" }}>
            <button onClick={logout}>Log Out</button>
          </div>
        </div>
      </div>
    </div>
  );
}
