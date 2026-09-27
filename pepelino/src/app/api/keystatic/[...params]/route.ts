import { makeRouteHandler } from "@keystatic/next/route-handler";
import config from "../../../../../keystatic.config";
import { cmsEnabled } from "@/lib/cms/enabled";

const handler = makeRouteHandler({ config });
const disabled = () => new Response("Not found", { status: 404 });

export const GET = cmsEnabled ? handler.GET : disabled;
export const POST = cmsEnabled ? handler.POST : disabled;
