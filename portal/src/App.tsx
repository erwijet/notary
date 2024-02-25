import { usePortalStore } from "./store";
import { Login } from "./pages/Login";
import { Portal } from "./pages/Portal";

export function App() {
  const token = usePortalStore(s => s.token);

  return typeof token == 'undefined' ? <Login /> : <Portal />
}
