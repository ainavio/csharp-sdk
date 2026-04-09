FROM mcr.microsoft.com/dotnet/sdk:8.0 AS csharp-sdk
RUN mkdir /package
COPY /Conductor /package/Conductor
COPY /README.md /package/Conductor/README.md
WORKDIR /package/Conductor

FROM csharp-sdk AS linter
RUN dotnet format --verify-no-changes *.csproj

FROM csharp-sdk AS build
RUN dotnet build *.csproj

FROM build AS pack_release
ARG SDK_VERSION
RUN dotnet pack conductor-csharp.csproj \
    -o /build \
    --include-symbols \
    --include-source \
    -c Release \
    "/p:Version=${SDK_VERSION}"

FROM pack_release AS publish_release
ARG NUGET_SRC
ARG NUGET_API_KEY
RUN dotnet nuget push "/build/*.symbols.nupkg" \
    --source "${NUGET_SRC}" \
    --api-key "${NUGET_API_KEY}"
