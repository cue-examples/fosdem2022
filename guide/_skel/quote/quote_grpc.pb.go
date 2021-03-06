// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.2.0
// - protoc             v3.19.3
// source: quote.proto

package quote

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

// QuoterClient is the client API for Quoter service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type QuoterClient interface {
	Quote(ctx context.Context, in *QuoteRequest, opts ...grpc.CallOption) (*QuoteResponse, error)
}

type quoterClient struct {
	cc grpc.ClientConnInterface
}

func NewQuoterClient(cc grpc.ClientConnInterface) QuoterClient {
	return &quoterClient{cc}
}

func (c *quoterClient) Quote(ctx context.Context, in *QuoteRequest, opts ...grpc.CallOption) (*QuoteResponse, error) {
	out := new(QuoteResponse)
	err := c.cc.Invoke(ctx, "/quote.Quoter/Quote", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// QuoterServer is the server API for Quoter service.
// All implementations must embed UnimplementedQuoterServer
// for forward compatibility
type QuoterServer interface {
	Quote(context.Context, *QuoteRequest) (*QuoteResponse, error)
	mustEmbedUnimplementedQuoterServer()
}

// UnimplementedQuoterServer must be embedded to have forward compatible implementations.
type UnimplementedQuoterServer struct {
}

func (UnimplementedQuoterServer) Quote(context.Context, *QuoteRequest) (*QuoteResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method Quote not implemented")
}
func (UnimplementedQuoterServer) mustEmbedUnimplementedQuoterServer() {}

// UnsafeQuoterServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to QuoterServer will
// result in compilation errors.
type UnsafeQuoterServer interface {
	mustEmbedUnimplementedQuoterServer()
}

func RegisterQuoterServer(s grpc.ServiceRegistrar, srv QuoterServer) {
	s.RegisterService(&Quoter_ServiceDesc, srv)
}

func _Quoter_Quote_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QuoteRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QuoterServer).Quote(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/quote.Quoter/Quote",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QuoterServer).Quote(ctx, req.(*QuoteRequest))
	}
	return interceptor(ctx, in, info, handler)
}

// Quoter_ServiceDesc is the grpc.ServiceDesc for Quoter service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var Quoter_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "quote.Quoter",
	HandlerType: (*QuoterServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Quote",
			Handler:    _Quoter_Quote_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "quote.proto",
}
